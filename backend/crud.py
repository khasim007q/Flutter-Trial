from sqlalchemy.orm import Session
from datetime import timedelta
import datetime

import models, schemas

def get_task(db: Session, task_id: int):
    return db.query(models.Task).filter(models.Task.id == task_id).first()

from sqlalchemy import or_

def get_tasks(db: Session, skip: int = 0, limit: int = 100, search: str = None, status: str = None):
    query = db.query(models.Task)
    
    if search:
        query = query.filter(
            or_(
                models.Task.title.ilike(f"%{search}%"),
                models.Task.description.ilike(f"%{search}%"),
                models.Task.due_date.cast(models.String).ilike(f"%{search}%")
            )
        )
    if status and status != "All":
        query = query.filter(models.Task.status == status)
    else:
        # If the task is recurring and status has been set to done then it shouldn't be shown in the all tab.
        query = query.filter(
            ~((models.Task.is_recurring == True) & (models.Task.status == "Done"))
        )
        
    tasks = query.offset(skip).limit(limit).all()
    total = query.count()
    return {"total": total, "tasks": tasks}

def create_task(db: Session, task: schemas.TaskCreate):
    db_task = models.Task(**task.model_dump())
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task

def update_task(db: Session, task_id: int, task: schemas.TaskUpdate):
    db_task = get_task(db, task_id)
    if not db_task:
        return None
        
    # Check if this task is being marked as Done and is recurring
    was_done = db_task.status == "Done"
    is_now_done = task.status == "Done"
    
    # Update fields
    for key, value in task.model_dump().items():
        setattr(db_task, key, value)
        
    db.commit()
    db.refresh(db_task)
    
    # Handle Recurring Logic
    if db_task.is_recurring and not was_done and is_now_done:
        # Generate a duplicate task pushed forward
        new_due_date = db_task.due_date
        if db_task.recurrence_type == "Daily":
            new_due_date += timedelta(days=1)
        elif db_task.recurrence_type == "Weekly":
            new_due_date += timedelta(days=7)
            
        new_task = models.Task(
            title=db_task.title,
            description=db_task.description,
            due_date=new_due_date,
            status="To-Do",
            is_recurring=True,
            recurrence_type=db_task.recurrence_type,
            blocked_by_id=db_task.blocked_by_id # Usually we want to keep the same block but could be null
        )
        db.add(new_task)
        db.commit()
        
    return db_task

def delete_task(db: Session, task_id: int):
    db_task = get_task(db, task_id)
    if db_task:
        db.delete(db_task)
        db.commit()
        return True
    return False
