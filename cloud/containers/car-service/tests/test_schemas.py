"""
Tests for Pydantic schemas.
"""
import pytest
from uuid import UUID, uuid4

from app.schemas import (
    Car, Engine, Performance, Dimensions, Drivetrain,
    MeasurementVolume, MeasurementPower, MeasurementTorque,
    MeasurementDuration, MeasurementSpeed, MeasurementLength, MeasurementMass,
    VolumeUnit, PowerUnit, TorqueUnit, SpeedUnit, LengthUnit, MassUnit,
    BodyStyle, FuelType, Induction, Transmission, DriveLayout
)


class TestMeasurementModels:
    """Tests for measurement models."""
    
    def test_measurement_volume_liters(self):
        """Test volume measurement in liters."""
        volume = MeasurementVolume(value=3.0, unit=VolumeUnit.liters)
        assert volume.value == 3.0
        assert volume.unit == VolumeUnit.liters
    
    def test_measurement_volume_gallons(self):
        """Test volume measurement in gallons."""
        volume = MeasurementVolume(value=15.6, unit=VolumeUnit.gallons)
        assert volume.value == 15.6
        assert volume.unit == VolumeUnit.gallons
    
    def test_measurement_power_horsepower(self):
        """Test power measurement in horsepower."""
        power = MeasurementPower(value=473, unit=PowerUnit.horsepower)
        assert power.value == 473
        assert power.unit == PowerUnit.horsepower
    
    def test_measurement_power_kilowatts(self):
        """Test power measurement in kilowatts."""
        power = MeasurementPower(value=350, unit=PowerUnit.kilowatts)
        assert power.value == 350
        assert power.unit == PowerUnit.kilowatts
    
    def test_measurement_torque_newton_meters(self):
        """Test torque measurement in newton meters."""
        torque = MeasurementTorque(value=550, unit=TorqueUnit.newtonMeters)
        assert torque.value == 550
        assert torque.unit == TorqueUnit.newtonMeters
    
    def test_measurement_torque_pound_feet(self):
        """Test torque measurement in pound-feet."""
        torque = MeasurementTorque(value=406, unit=TorqueUnit.poundForceFeet)
        assert torque.value == 406
        assert torque.unit == TorqueUnit.poundForceFeet
    
    def test_measurement_speed_mph(self):
        """Test speed measurement in mph."""
        speed = MeasurementSpeed(value=155, unit=SpeedUnit.milesPerHour)
        assert speed.value == 155
        assert speed.unit == SpeedUnit.milesPerHour
    
    def test_measurement_speed_kph(self):
        """Test speed measurement in km/h."""
        speed = MeasurementSpeed(value=250, unit=SpeedUnit.kilometersPerHour)
        assert speed.value == 250
        assert speed.unit == SpeedUnit.kilometersPerHour
    
    def test_measurement_length_inches(self):
        """Test length measurement in inches."""
        length = MeasurementLength(value=189.1, unit=LengthUnit.inches)
        assert length.value == 189.1
        assert length.unit == LengthUnit.inches
    
    def test_measurement_mass_pounds(self):
        """Test mass measurement in pounds."""
        mass = MeasurementMass(value=3830, unit=MassUnit.pounds)
        assert mass.value == 3830
        assert mass.unit == MassUnit.pounds


class TestEnums:
    """Tests for enum values."""
    
    def test_body_style_values(self):
        """Test BodyStyle enum values."""
        assert BodyStyle.sedan == "Sedan"
        assert BodyStyle.coupe == "Coupe"
        assert BodyStyle.suv == "SUV"
        assert BodyStyle.hatchback == "Hatchback"
        assert BodyStyle.wagon == "Wagon"
    
    def test_fuel_type_values(self):
        """Test FuelType enum values."""
        assert FuelType.gasoline == "gasoline"
        assert FuelType.diesel == "diesel"
        assert FuelType.electric == "electric"
        assert FuelType.hybrid == "hybrid"
    
    def test_drive_layout_values(self):
        """Test DriveLayout enum values."""
        assert DriveLayout.fwd == "fwd"
        assert DriveLayout.rwd == "rwd"
        assert DriveLayout.awd == "awd"
        assert DriveLayout.fourwd == "fourwd"
    
    def test_transmission_values(self):
        """Test Transmission enum values."""
        assert Transmission.manual == "manual"
        assert Transmission.automatic == "automatic"
        assert Transmission.dct == "dct"
        assert Transmission.cvt == "cvt"


class TestEngine:
    """Tests for Engine model."""
    
    def test_engine_with_all_fields(self):
        """Test Engine with all fields populated."""
        engine = Engine(
            displacement=MeasurementVolume(value=3.0, unit=VolumeUnit.liters),
            cylinders=6,
            configuration="I6",
            fuel=FuelType.gasoline,
            induction=Induction.turbocharged,
            code="S58"
        )
        
        assert engine.displacement.value == 3.0
        assert engine.cylinders == 6
        assert engine.configuration == "I6"
        assert engine.fuel == FuelType.gasoline
        assert engine.induction == Induction.turbocharged
        assert engine.code == "S58"
    
    def test_engine_with_minimal_fields(self):
        """Test Engine with only required fields (none)."""
        engine = Engine()
        
        assert engine.displacement is None
        assert engine.cylinders is None
        assert engine.configuration is None


class TestPerformance:
    """Tests for Performance model."""
    
    def test_performance_with_all_fields(self):
        """Test Performance with all fields."""
        perf = Performance(
            horsepower=MeasurementPower(value=473, unit=PowerUnit.horsepower),
            torque=MeasurementTorque(value=406, unit=TorqueUnit.poundForceFeet),
            zeroToSixty=MeasurementDuration(value=4.1),
            topSpeed=MeasurementSpeed(value=155, unit=SpeedUnit.milesPerHour)
        )
        
        assert perf.horsepower.value == 473
        assert perf.torque.value == 406
        assert perf.zeroToSixty.value == 4.1
        assert perf.topSpeed.value == 155


class TestDimensions:
    """Tests for Dimensions model."""
    
    def test_dimensions_with_all_fields(self):
        """Test Dimensions with all fields."""
        dims = Dimensions(
            wheelbase=MeasurementLength(value=112.8, unit=LengthUnit.inches),
            length=MeasurementLength(value=189.1, unit=LengthUnit.inches),
            width=MeasurementLength(value=74.3, unit=LengthUnit.inches),
            height=MeasurementLength(value=56.9, unit=LengthUnit.inches),
            curbWeight=MeasurementMass(value=3830, unit=MassUnit.pounds)
        )
        
        assert dims.wheelbase.value == 112.8
        assert dims.length.value == 189.1
        assert dims.width.value == 74.3
        assert dims.height.value == 56.9
        assert dims.curbWeight.value == 3830


class TestDrivetrain:
    """Tests for Drivetrain model."""
    
    def test_drivetrain_rwd_manual(self):
        """Test Drivetrain with RWD and manual transmission."""
        drive = Drivetrain(
            layout=DriveLayout.rwd,
            transmission=Transmission.manual,
            gears=6,
            differential="Active differential"
        )
        
        assert drive.layout == DriveLayout.rwd
        assert drive.transmission == Transmission.manual
        assert drive.gears == 6
        assert drive.differential == "Active differential"
    
    def test_drivetrain_awd_automatic(self):
        """Test Drivetrain with AWD and automatic transmission."""
        drive = Drivetrain(
            layout=DriveLayout.awd,
            transmission=Transmission.automatic,
            gears=8
        )
        
        assert drive.layout == DriveLayout.awd
        assert drive.transmission == Transmission.automatic
        assert drive.gears == 8


class TestCar:
    """Tests for Car model."""
    
    def test_car_with_required_fields(self):
        """Test Car with only required fields."""
        car = Car(make="BMW", model="M3")
        
        assert car.make == "BMW"
        assert car.model == "M3"
        assert car.id is not None  # Auto-generated UUID
    
    def test_car_with_all_fields(self, sample_car_data):
        """Test Car with all fields populated."""
        car = Car(**sample_car_data)
        
        assert car.make == sample_car_data["make"]
        assert car.model == sample_car_data["model"]
        assert car.year == sample_car_data["year"]
        assert car.bodyStyle == BodyStyle.sedan
        assert car.engine is not None
        assert car.performance is not None
        assert car.dimensions is not None
        assert car.drivetrain is not None
    
    def test_car_id_is_uuid(self):
        """Test that car ID is a valid UUID."""
        car = Car(make="Toyota", model="Supra")
        
        assert isinstance(car.id, UUID)
    
    def test_car_custom_id(self):
        """Test Car with custom UUID."""
        custom_id = uuid4()
        car = Car(id=custom_id, make="Audi", model="RS7")
        
        assert car.id == custom_id
    
    def test_car_year_validation(self):
        """Test Car year field validation."""
        # Valid year
        car = Car(make="Test", model="Car", year=2024)
        assert car.year == 2024
        
        # Edge cases
        car_old = Car(make="Test", model="Car", year=1886)  # First car
        assert car_old.year == 1886
    
    def test_car_json_serialization(self, sample_car_data):
        """Test Car serialization to JSON."""
        car = Car(**sample_car_data)
        json_data = car.model_dump(mode='json')
        
        assert json_data["make"] == "BMW"
        assert json_data["model"] == "M3"
        assert isinstance(json_data["id"], str)  # UUID should be string in JSON
    
    def test_car_other_specs(self):
        """Test Car with otherSpecs dictionary."""
        car = Car(
            make="BMW",
            model="M3",
            otherSpecs={
                "feature1": "value1",
                "feature2": "value2"
            }
        )
        
        assert car.otherSpecs["feature1"] == "value1"
        assert car.otherSpecs["feature2"] == "value2"

