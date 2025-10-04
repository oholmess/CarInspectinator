#!/usr/bin/env python3
"""
Script to seed Firestore with car data from schemas.py

Usage:
    python seed_firestore.py
    
Prerequisites:
    - Set GOOGLE_APPLICATION_CREDENTIALS environment variable to your service account key
    - Or run in GCP environment with appropriate permissions
"""

import sys
import logging
from pathlib import Path

# Add the current directory to the path so we can import app modules
sys.path.insert(0, str(Path(__file__).parent))

from app.firebase import initialize_firebase, get_firestore_client
from app.schemas import (
    Car, BodyStyle, Engine, Performance, Dimensions, Drivetrain,
    MeasurementVolume, VolumeUnit, MeasurementPower, PowerUnit,
    MeasurementTorque, TorqueUnit, MeasurementDuration, DurationUnit,
    MeasurementSpeed, SpeedUnit, MeasurementLength, LengthUnit,
    MeasurementMass, MassUnit, MeasurementFuelEfficiency, FuelEfficiencyUnit,
    FuelType, Induction, Transmission, DriveLayout
)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

CARS_COLLECTION = "cars"


def create_cars_data():
    """Create all car objects with their specifications."""
    
    cars = []
    
    # Volkswagen Golf GTI
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
            fuel=FuelType.diesel,
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
    cars.append(gti)

    # BMW M3
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
    cars.append(m3)

    # Audi RS7
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
    cars.append(rs7)

    # Mercedes G63
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
    cars.append(g63)

    # Toyota Supra
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
    cars.append(supra)
    
    return cars


def seed_firestore():
    """Seed Firestore with car data."""
    
    logger.info("Initializing Firebase...")
    initialize_firebase()
    
    db = get_firestore_client()
    logger.info("Creating car data...")
    cars = create_cars_data()
    
    logger.info(f"Seeding {len(cars)} cars to Firestore...")
    
    success_count = 0
    for car in cars:
        try:
            car_id = str(car.id)
            car_data = car.model_dump(mode='json', exclude={'id'})
            
            db.collection(CARS_COLLECTION).document(car_id).set(car_data)
            logger.info(f"✓ Added {car.make} {car.model} (ID: {car_id})")
            success_count += 1
            
        except Exception as e:
            logger.error(f"✗ Failed to add {car.make} {car.model}: {e}")
    
    logger.info(f"\n{'='*60}")
    logger.info(f"Seeding complete! {success_count}/{len(cars)} cars added successfully")
    logger.info(f"{'='*60}")


if __name__ == "__main__":
    try:
        seed_firestore()
    except Exception as e:
        logger.error(f"Seeding failed: {e}")
        sys.exit(1)

