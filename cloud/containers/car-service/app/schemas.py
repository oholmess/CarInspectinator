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
# In-memory database (DEPRECATED - now using Firestore)
# ---------------------------
# DB: Dict[UUID, Car] = {}


# ---------------------------
# Example seed data (moved to seed_firestore.py)
# Use: python seed_firestore.py to populate Firestore
# ---------------------------

def _seed_inmemory() -> None:
    """
    DEPRECATED: This function was used for in-memory database seeding.
    Now use seed_firestore.py to populate Firestore instead.
    """
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
    # DB[gti.id] = gti
    pass

def _seed_example_m3() -> None:
    """Example car data - BMW M3"""
    m3 = Car(
        make="BMW",
        model="M3",
        iconAssetName="bmw_m3",
        year=2020,
        bodyStyle=BodyStyle.sedan,
        volumeId="BMW_M4_f82",
        engine=Engine(
            displacement=MeasurementVolume(value=3.0, unit=VolumeUnit.liters),
            cylinders=6,
            configuration="I6",
            fuel=FuelType.gasoline,
            induction=Induction.turbocharged,
            code="S58",
        ),
        performance=Performance(
            horsepower=MeasurementPower(value=473, unit=PowerUnit.horsepower),
            torque=MeasurementTorque(value=406, unit=TorqueUnit.poundForceFeet),
            zeroToSixty=MeasurementDuration(value=4.1, unit=DurationUnit.seconds),
            topSpeed=MeasurementSpeed(value=155, unit=SpeedUnit.milesPerHour),
            epaCity=MeasurementFuelEfficiency(value=16, unit=FuelEfficiencyUnit.milesPerGallon),
            epaHighway=MeasurementFuelEfficiency(value=23, unit=FuelEfficiencyUnit.milesPerGallon),
        ),
        dimensions=Dimensions(
            wheelbase=MeasurementLength(value=112.8, unit=LengthUnit.inches),
            length=MeasurementLength(value=189.1, unit=LengthUnit.inches),
            width=MeasurementLength(value=74.3, unit=LengthUnit.inches),
            height=MeasurementLength(value=56.9, unit=LengthUnit.inches),
            curbWeight=MeasurementMass(value=3830, unit=MassUnit.pounds),
            fuelTank=MeasurementVolume(value=15.6, unit=VolumeUnit.gallons),
        ),
        drivetrain=Drivetrain(
            layout=DriveLayout.rwd,
            differential="Electronically controlled limited-slip (M Differential)",
            transmission=Transmission.manual,
            gears=6,
        ),
        otherSpecs={
            "altTransmission": "8-speed M Steptronic automatic",
            "features": "M Sport exhaust, Adaptive M suspension",
        },
    )
    # DB[m3.id] = m3
    pass

def _seed_example_rs7() -> None:
    """Example car data - Audi RS7"""
    rs7 = Car(
        make="Audi",
        model="RS7",
        iconAssetName="audi_rs7",
        year=2020,
        bodyStyle=BodyStyle.sedan,
        volumeId="2020_Audi_RS7_Sportback",
        engine=Engine(
            displacement=MeasurementVolume(value=4.0, unit=VolumeUnit.liters),
            cylinders=8,
            configuration="V8",
            fuel=FuelType.gasoline,
            induction=Induction.turbocharged,
        ),
        performance=Performance(
            horsepower=MeasurementPower(value=591, unit=PowerUnit.horsepower),
            torque=MeasurementTorque(value=590, unit=TorqueUnit.poundForceFeet),
            zeroToSixty=MeasurementDuration(value=3.5, unit=DurationUnit.seconds),
            topSpeed=MeasurementSpeed(value=190, unit=SpeedUnit.milesPerHour),
            epaCity=MeasurementFuelEfficiency(value=15, unit=FuelEfficiencyUnit.milesPerGallon),
            epaHighway=MeasurementFuelEfficiency(value=22, unit=FuelEfficiencyUnit.milesPerGallon),
        ),
        dimensions=Dimensions(
            wheelbase=MeasurementLength(value=116.7, unit=LengthUnit.inches),
            length=MeasurementLength(value=196.5, unit=LengthUnit.inches),
            width=MeasurementLength(value=77.0, unit=LengthUnit.inches),
            height=MeasurementLength(value=55.7, unit=LengthUnit.inches),
            curbWeight=MeasurementMass(value=4575, unit=MassUnit.pounds),
            cargoRearSeatsUp=MeasurementVolume(value=24.9, unit=VolumeUnit.gallons),
            fuelTank=MeasurementVolume(value=21.9, unit=VolumeUnit.gallons),
        ),
        drivetrain=Drivetrain(
            layout=DriveLayout.awd,
            differential="Sport differential with torque vectoring (Quattro)",
            transmission=Transmission.automatic,
            gears=8,
        ),
        otherSpecs={
            "features": "48-volt mild hybrid system, Dynamic all-wheel steering",
            "carbonCeramicBrakes": "Optional",
        },
    )
    # DB[rs7.id] = rs7
    pass

def _seed_example_g63() -> None:
    """Example car data - Mercedes G63"""
    g63 = Car(
        make="Mercedes",
        model="G63",
        iconAssetName="mercedes_g63",
        year=2020,
        bodyStyle=BodyStyle.suv,
        volumeId="2020_Mercedes-Benz_G-Class_AMG_G63",
        engine=Engine(
            displacement=MeasurementVolume(value=4.0, unit=VolumeUnit.liters),
            cylinders=8,
            configuration="V8",
            fuel=FuelType.gasoline,
            induction=Induction.turbocharged,
            code="M177",
        ),
        performance=Performance(
            horsepower=MeasurementPower(value=577, unit=PowerUnit.horsepower),
            torque=MeasurementTorque(value=627, unit=TorqueUnit.poundForceFeet),
            zeroToSixty=MeasurementDuration(value=4.5, unit=DurationUnit.seconds),
            topSpeed=MeasurementSpeed(value=137, unit=SpeedUnit.milesPerHour),
            epaCity=MeasurementFuelEfficiency(value=13, unit=FuelEfficiencyUnit.milesPerGallon),
            epaHighway=MeasurementFuelEfficiency(value=15, unit=FuelEfficiencyUnit.milesPerGallon),
        ),
        dimensions=Dimensions(
            wheelbase=MeasurementLength(value=113.0, unit=LengthUnit.inches),
            length=MeasurementLength(value=189.6, unit=LengthUnit.inches),
            width=MeasurementLength(value=83.1, unit=LengthUnit.inches),
            height=MeasurementLength(value=78.1, unit=LengthUnit.inches),
            curbWeight=MeasurementMass(value=5842, unit=MassUnit.pounds),
            cargoRearSeatsUp=MeasurementVolume(value=38.0, unit=VolumeUnit.gallons),
            fuelTank=MeasurementVolume(value=26.4, unit=VolumeUnit.gallons),
        ),
        drivetrain=Drivetrain(
            layout=DriveLayout.fourwd,
            differential="Three locking differentials (front, center, rear)",
            transmission=Transmission.automatic,
            gears=9,
        ),
        otherSpecs={
            "features": "AMG Performance exhaust, AMG Ride Control suspension",
            "offRoad": "Ground clearance: 9.5 inches",
        },
    )
    # DB[g63.id] = g63
    pass

def _seed_example_supra() -> None:
    """Example car data - Toyota Supra"""
    supra = Car(
        make="Toyota",
        model="Supra",
        iconAssetName="toyota_supra",
        year=2020,
        bodyStyle=BodyStyle.coupe,
        volumeId="Toyota_Supra",
        engine=Engine(
            displacement=MeasurementVolume(value=3.0, unit=VolumeUnit.liters),
            cylinders=6,
            configuration="I6",
            fuel=FuelType.gasoline,
            induction=Induction.turbocharged,
            code="B58",
        ),
        performance=Performance(
            horsepower=MeasurementPower(value=335, unit=PowerUnit.horsepower),
            torque=MeasurementTorque(value=365, unit=TorqueUnit.poundForceFeet),
            zeroToSixty=MeasurementDuration(value=4.1, unit=DurationUnit.seconds),
            topSpeed=MeasurementSpeed(value=155, unit=SpeedUnit.milesPerHour),
            epaCity=MeasurementFuelEfficiency(value=24, unit=FuelEfficiencyUnit.milesPerGallon),
            epaHighway=MeasurementFuelEfficiency(value=31, unit=FuelEfficiencyUnit.milesPerGallon),
        ),
        dimensions=Dimensions(
            wheelbase=MeasurementLength(value=97.2, unit=LengthUnit.inches),
            length=MeasurementLength(value=172.5, unit=LengthUnit.inches),
            width=MeasurementLength(value=73.0, unit=LengthUnit.inches),
            height=MeasurementLength(value=50.9, unit=LengthUnit.inches),
            curbWeight=MeasurementMass(value=3397, unit=MassUnit.pounds),
            cargoRearSeatsUp=MeasurementVolume(value=10.2, unit=VolumeUnit.gallons),
            fuelTank=MeasurementVolume(value=13.7, unit=VolumeUnit.gallons),
        ),
        drivetrain=Drivetrain(
            layout=DriveLayout.rwd,
            differential="Active differential",
            transmission=Transmission.automatic,
            gears=8,
        ),
        otherSpecs={
            "features": "Adaptive suspension, Launch control",
            "collaboration": "Co-developed with BMW",
        },
    )
    # DB[supra.id] = supra
    pass


# DEPRECATED: In-memory database seeding is no longer used
# Use seed_firestore.py to populate Firestore instead
# _seed()
