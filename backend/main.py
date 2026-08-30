from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from database import init_db
from routers import incidents, crowd_reports, routes, supplies, facilities, river_zones, alerts, missing_persons, halts, tasks
from models.incident import IncidentCreateRequest, IncidentResponse
from repositories.incident_repository import IncidentRepository


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize SQLite database schema
    init_db()
    yield


app = FastAPI(title="SevakConnect Backend", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(incidents.router)
app.include_router(crowd_reports.router)
app.include_router(routes.router)
app.include_router(supplies.router)
app.include_router(facilities.router)
app.include_router(river_zones.router)
app.include_router(alerts.router)
app.include_router(missing_persons.router)
app.include_router(halts.router)
app.include_router(tasks.router)


@app.post("/sos", response_model=IncidentResponse, status_code=201, summary="Emergency SOS trigger", tags=["Emergency SOS"])
def trigger_sos(req: IncidentCreateRequest):
    """Direct SOS endpoint for urgent volunteer alerts."""
    req.type = "sos"
    req.severity = "critical"
    return IncidentRepository.create(req)


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