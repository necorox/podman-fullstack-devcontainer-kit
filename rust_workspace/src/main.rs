use actix_web::{get, web, App, HttpServer, HttpResponse, Responder, HttpRequest, HttpMessage};
use actix_web::middleware::Logger;
use jsonwebtoken::{decode, decode_header, DecodingKey, Validation, Algorithm};
use serde::{Deserialize, Serialize};
use std::env;

#[derive(Debug, Serialize, Deserialize)]
struct Claims {
    sub: String,
    exp: usize,
    iss: String,
    aud: String,
}

#[derive(Clone)]
struct AppState {
    authentik_jwks_url: String,
}

async fn fetch_jwks(url: &str) -> Result<jsonwebtoken::jwk::JwkSet, Box<dyn std::error::Error>> {
    let resp = reqwest::get(url).await?;
    let jwks = resp.json::<jsonwebtoken::jwk::JwkSet>().await?;
    Ok(jwks)
}

#[get("/protected")]
async fn protected(req: HttpRequest, data: web::Data<AppState>) -> impl Responder {
    if let Some(auth_header) = req.headers().get("Authorization") {
        if let Ok(auth_str) = auth_header.to_str() {
            if auth_str.starts_with("Bearer ") {
                let token = &auth_str[7..];
                
                // In a real app, you would cache the JWKS
                match fetch_jwks(&data.authentik_jwks_url).await {
                    Ok(jwks) => {
                        let header = match decode_header(token) {
                            Ok(h) => h,
                            Err(_) => return HttpResponse::Unauthorized().body("Invalid token header"),
                        };

                        if let Some(kid) = header.kid {
                            if let Some(j) = jwks.find(&kid) {
                                match DecodingKey::from_jwk(j) {
                                    Ok(decoding_key) => {
                                        let validation = Validation::new(Algorithm::RS256);
                                        // Configure validation (audience, issuer, etc.)
                                        // validation.set_audience(&["my-app-slug"]);
                                        
                                        match decode::<Claims>(token, &decoding_key, &validation) {
                                            Ok(token_data) => {
                                                return HttpResponse::Ok().body(format!("Access granted for user: {}", token_data.claims.sub));
                                            },
                                            Err(e) => return HttpResponse::Unauthorized().body(format!("Invalid token: {}", e)),
                                        }
                                    },
                                    Err(_) => return HttpResponse::InternalServerError().body("Failed to create decoding key"),
                                }
                            }
                        }
                        return HttpResponse::Unauthorized().body("Unknown key ID");
                    },
                    Err(e) => {
                        log::error!("Failed to fetch JWKS: {}", e);
                        return HttpResponse::InternalServerError().body("Auth service unavailable");
                    }
                }
            }
        }
    }
    
    HttpResponse::Unauthorized().body("Missing or invalid token")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    env_logger::init_from_env(env_logger::Env::new().default_filter_or("info"));

    let authentik_host = env::var("AUTHENTIK_HOST").unwrap_or_else(|_| "http://authentik-server:9000".to_string());
    let app_slug = env::var("AUTHENTIK_APP_SLUG").unwrap_or_else(|_| "dev".to_string());
    let jwks_url = format!("{}/application/o/{}/jwks/", authentik_host, app_slug);

    log::info!("Starting HTTP server at http://0.0.0.0:8080");
    log::info!("Using Authentik JWKS URL: {}", jwks_url);

    let app_state = AppState {
        authentik_jwks_url: jwks_url,
    };

    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(app_state.clone()))
            .wrap(Logger::default())
            .service(web::resource("/").to(index))
            .service(protected)
    })
    .bind(("0.0.0.0", 8080))?
    .run()
    .await
}
