from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="SevakConnect Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {
        "message": "SevakConnect backend is running"
    }


@app.get("/health")
def health():
    return {
        "status": "ok",
        "message": "SevakConnect backend is connected"
    }