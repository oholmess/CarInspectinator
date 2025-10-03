# app.py
from __future__ import annotations

from enum import Enum
from typing import Optional, Dict, List
from uuid import UUID, uuid4

from fastapi import FastAPI
from pydantic import BaseModel, Field


# ---------------------------
# Measurement helpers
# ---------------------------

class VolumeUnit(str, Enum):
    liters = "liters"
    gallons = "gallons"


class PowerUnit(str, Enum):
    horsepower = "horsepower"
    kilowatts = "kilowatts"


class TorqueUnit(str, Enum):
    newtonMeters = "newtonMeters"
    poundForceFeet = "poundForceFeet"


class DurationUnit(str, Enum):
    seconds = "seconds"


class SpeedUnit(str, Enum):
    kilometersPerHour = "kilometersPerHour"
    milesPerHour = "milesPerHour"


class LengthUnit(str, Enum):
    millimeters = "millimeters"
    centimeters = "centimeters"
    inches = "inches"
    meters = "meters"


class MassUnit(str, Enum):
    kilograms = "kilograms"
    pounds = "pounds"


class FuelEfficiencyUnit(str, Enum):
    milesPerGallon = "milesPerGallon"
    litersPer100km = "litersPer100km"


class MeasurementVolume(BaseModel):
    value: float
    unit: VolumeUnit


class MeasurementPower(BaseModel):
    value: float
    unit: PowerUnit


class MeasurementTorque(BaseModel):
    value: float
    unit: TorqueUnit


class MeasurementDuration(BaseModel):
    value: float
    unit: DurationUnit = DurationUnit.seconds


class MeasurementSpeed(BaseModel):
    value: float
    unit: SpeedUnit


class MeasurementLength(BaseModel):
    value: float
    unit: LengthUnit


class MeasurementMass(BaseModel):
    value: float
    unit: MassUnit


class MeasurementFuelEfficiency(BaseModel):
    value: float
    unit: FuelEfficiencyUnit


# ---------------------------
# Enums (match Swift raw values)
# ---------------------------

class BodyStyle(str, Enum):
    coupe = "Coupe"
    hatchback = "Hatchback"
    sedan = "Sedan"
    suv = "SUV"
    wagon = "Wagon"
    truck = "Truck"
    minivan = "Minivan"
    other = "Other"
    notSpecified = "Not Specified"


class FuelType(str, Enum):
    gasoline = "gasoline"
    diesel = "diesel"
    hybrid = "hybrid"
    plugInHybrid = "plugInHybrid"
    electric = "electric"
    hydrogen = "hydrogen"
    other = "other"


class Induction(str, Enum):
    naturallyAspirated = "naturallyAspirated"
    turbocharged = "turbocharged"
    supercharged = "supercharged"
    twinCharged = "twinCharged"
    other = "other"


class Transmission(str, Enum):
    manual = "manual"
    automatic = "automatic"
    dct = "dct"
    cvt = "cvt"
    other = "other"


class DriveLayout(str, Enum):
    fwd = "fwd"
    rwd = "rwd"
    awd = "awd"
    fourwd = "fourwd"
    other = "other"


# ---------------------------
# Nested structures
# ---------------------------

class Engine(BaseModel):
    displacement: Optional[MeasurementVolume] = None  # liters or gallons; prefer liters
    cylinders: Optional[int] = Field(default=None, ge=1)
    configuration: Optional[str] = None   # e.g., "I4", "V6", "B6"
    fuel: Optional[FuelType] = None
    induction: Optional[Induction] = None
    code: Optional[str] = None            # e.g., "EA888"


class Performance(BaseModel):
    horsepower: Optional[MeasurementPower] = None
    torque: Optional[MeasurementTorque] = None
    zeroToSixty: Optional[MeasurementDuration] = None
    topSpeed: Optional[MeasurementSpeed] = None
    epaCity: Optional[MeasurementFuelEfficiency] = None
    epaHighway: Optional[MeasurementFuelEfficiency] = None


class Dimensions(BaseModel):
    wheelbase: Optional[MeasurementLength] = None
    length: Optional[MeasurementLength] = None
    width: Optional[MeasurementLength] = None
    height: Optional[MeasurementLength] = None
    curbWeight: Optional[MeasurementMass] = None
    cargoRearSeatsUp: Optional[MeasurementVolume] = None
    fuelTank: Optional[MeasurementVolume] = None


class Drivetrain(BaseModel):
    layout: Optional[DriveLayout] = None
    differential: Optional[str] = None     # e.g., "Front limited-slip (VAQ)"
    transmission: Optional[Transmission] = None
    gears: Optional[int] = Field(default=None, ge=1, le=12)


# ---------------------------
# Car model
# ---------------------------

class Car(BaseModel):
    # Required
    id: UUID = Field(default_factory=uuid4)
    make: str
    model: str

    # Optional / nice-to-have
    blurb: Optional[str] = None
    iconAssetName: Optional[str] = None
    year: Optional[int] = Field(default=None, ge=1886, le=3000)
    bodyStyle: Optional[BodyStyle] = None
    exteriorColor: Optional[str] = None
    interiorColor: Optional[str] = None
    interiorPanoramaAssetName: Optional[str] = None
    volumeId: Optional[str] = None

    # Typed substructures
    engine: Optional[Engine] = None
    performance: Optional[Performance] = None
    dimensions: Optional[Dimensions] = None
    drivetrain: Optional[Drivetrain] = None

    # Escape hatch
    otherSpecs: Dict[str, str] = Field(default_factory=dict)

    class Config:
        # Keep the exact field names (camelCase) to match Swift Codable payloads
        populate_by_name = True
        json_encoders = {
            UUID: str
        }



# ---------------------------
# In-memory database (for development/testing)
# ---------------------------
DB: Dict[UUID, Car] = {}


# ---------------------------
# Example seed (optional)
# ---------------------------

def _seed() -> None:
    gti = Car(
        make="Volkswagen",
        model="Golf GTI",
        iconAssetName="vw_gti",
        year=2020,
        bodyStyle=BodyStyle.hatchback,
        volumeId="vw_golf_5_gti",
        engine=Engine(
            displacement=MeasurementVolume(value=1.8, unit=VolumeUnit.liters),
            cylinders=4,
            configuration="I4",
            fuel=FuelType.diesel,            # change to gasoline if needed
            induction=Induction.turbocharged,
        ),
        performance=Performance(
            horsepower=MeasurementPower(value=330, unit=PowerUnit.horsepower),
            torque=MeasurementTorque(value=258, unit=TorqueUnit.poundForceFeet),
        ),
        dimensions=Dimensions(
            wheelbase=MeasurementLength(value=103.6, unit=LengthUnit.inches),
            length=MeasurementLength(value=168.0, unit=LengthUnit.inches),
            curbWeight=MeasurementMass(value=3128, unit=MassUnit.pounds),
            cargoRearSeatsUp=MeasurementVolume(value=22.8, unit=VolumeUnit.gallons),
        ),
        drivetrain=Drivetrain(
            layout=DriveLayout.fwd,
            differential="Front limited-slip (VAQ)",
            transmission=Transmission.manual,
            gears=6,
        ),
        otherSpecs={
            "epaMPG": "24 city / 32 highway",
            "altTransmission": "7-speed DSG",
        },
    )
    DB[gti.id] = gti


_seed()
