from sqlalchemy.orm import Session
from typing import List, Optional
from datetime import datetime
from models.car_loan import CarLoan
from schemas.car_loan import CarLoanCreate

def create_car_loan(db: Session, car_loan: CarLoanCreate) -> CarLoan:
    db_car_loan = CarLoan(**car_loan.dict())
    db.add(db_car_loan)
    db.commit()
    db.refresh(db_car_loan)
    return db_car_loan

def get_car_loans(
    db: Session, 
    skip: int = 0, 
    limit: int = 100,
    start_date: Optional[datetime] = None,
    end_date: Optional[datetime] = None
) -> List[CarLoan]:
    query = db.query(CarLoan)
    
    if start_date:
        query = query.filter(
            (CarLoan.year > start_date.year) | 
            ((CarLoan.year == start_date.year) & (CarLoan.month >= start_date.strftime('%B')))
        )
    
    if end_date:
        query = query.filter(
            (CarLoan.year < end_date.year) | 
            ((CarLoan.year == end_date.year) & (CarLoan.month <= end_date.strftime('%B')))
        )
    
    # Sort by year desc, then by month number desc
    return query.order_by(CarLoan.year.desc(), _get_month_order()).offset(skip).limit(limit).all()

def get_car_loan(db: Session, car_loan_id: int) -> Optional[CarLoan]:
    return db.query(CarLoan).filter(CarLoan.id == car_loan_id).first()

def update_car_loan(db: Session, car_loan_id: int, car_loan: CarLoanCreate) -> Optional[CarLoan]:
    db_car_loan = db.query(CarLoan).filter(CarLoan.id == car_loan_id).first()
    if db_car_loan:
        for key, value in car_loan.dict().items():
            setattr(db_car_loan, key, value)
        db.commit()
        db.refresh(db_car_loan)
    return db_car_loan

def delete_car_loan(db: Session, car_loan_id: int) -> bool:
    db_car_loan = db.query(CarLoan).filter(CarLoan.id == car_loan_id).first()
    if db_car_loan:
        db.delete(db_car_loan)
        db.commit()
        return True
    return False

def get_latest_car_loan(db: Session) -> Optional[CarLoan]:
    return db.query(CarLoan).order_by(CarLoan.year.desc(), _get_month_order()).first()

def get_total_interest_paid(db: Session) -> float:
    result = db.query(CarLoan.finance).all()
    return sum(row[0] for row in result if row[0] is not None)

def get_total_principal_paid(db: Session) -> float:
    result = db.query(CarLoan.principal).all()
    return sum(row[0] for row in result if row[0] is not None)

def get_total_payments(db: Session) -> float:
    result = db.query(CarLoan.amount_paid).all()
    return sum(row[0] for row in result if row[0] is not None)

def _get_month_order():
    """Helper function to get month order for sorting"""
    from sqlalchemy import case
    return case(
        {
            'January': 1, 'February': 2, 'March': 3, 'April': 4,
            'May': 5, 'June': 6, 'July': 7, 'August': 8,
            'September': 9, 'October': 10, 'November': 11, 'December': 12
        },
        value=CarLoan.month
    ).desc() 