from fastapi import FastAPI
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Float, String, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import sys
import os
 # Import your machine learning model
from joblib import load  # Correct import for joblib

# Append the correct directory to sys.path
sys.path.append("C:/Users/aayushi pandey/OneDrive/Desktop/blockchain/ML part")

app = FastAPI()

Base = declarative_base()

class Model(Base):
    __tablename__ = "model_data"
    id = Column(Integer, primary_key=True, index=True)
    accuracy = Column(Float)
    precision = Column(String)  # Change the category name to "precision"

DATABASE_URL = "mysql://root:Ankush%401978@127.0.0.1:3306/Neu"
engine = create_engine(DATABASE_URL)
Base.metadata.create_all(bind=engine)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Correct function to load your machine learning model
loaded_model = load("C:/Users/aayushi pandey/OneDrive/Desktop/blockchain/ML part/lasso_model.joblib")

class DataPayload(BaseModel):
    accuracy: float
    precision: str  

@app.post("/store_data")
def store_data(payload: DataPayload):
    accuracy = payload.accuracy

    db = SessionLocal()
    db_data = Model(accuracy=accuracy, precision=payload.precision)  # Change the category name to "precision"
    db.add(db_data)
    db.commit()
    db.refresh(db_data)
    db.close()

    return {"message": "Data stored successfully", "accuracy": accuracy}

@app.get("/get_data")
def get_data():
    db = SessionLocal()
    result = db.query(Model).all()
    db.close()
    features = [[data.accuracy, data.precision] for data in result]  

    predictions = loaded_model.predict(features)

    response_data = [
        {
            "id": data.id,
            "accuracy": data.accuracy,
            "precision": data.precision,  # Change the category name to "precision"
            "prediction": prediction
        }
        for data, prediction in zip(result, predictions)
    ]

    return {"data": response_data}
