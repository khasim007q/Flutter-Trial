from fastapi import FastAPI, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from fastapi.middleware.cors import CORSMiddleware
from typing import List

import crud, models, schemas
from database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Task Management API")

# Allow CORS for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # For dev only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.post("/tasks/", response_model=schemas.Task)
def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    # Optional Validation: Check if blocked_by_id exists
    if task.blocked_by_id:
        blocking_task = crud.get_task(db, task.blocked_by_id)
        if not blocking_task:
            raise HTTPException(status_code=400, detail="Blocking task not found")
            
    return crud.create_task(db=db, task=task)


@app.get("/tasks/", response_model=schemas.PaginatedTasks)
def read_tasks(
    skip: int = 0, 
    limit: int = 100, 
    search: str = Query(None, description="Search term for task title"),
    status: str = Query(None, description="Filter by status (To-Do, In Progress, Done)"),
    db: Session = Depends(get_db)
):
    return crud.get_tasks(db, skip=skip, limit=limit, search=search, status=status)


@app.get("/tasks/{task_id}", response_model=schemas.Task)
def read_task(task_id: int, db: Session = Depends(get_db)):
    db_task = crud.get_task(db, task_id=task_id)
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task


@app.put("/tasks/{task_id}", response_model=schemas.Task)
def update_task(task_id: int, task: schemas.TaskUpdate, db: Session = Depends(get_db)):
    # Check if blocking task exists
    if task.blocked_by_id and task.blocked_by_id != task_id:
        blocking_task = crud.get_task(db, task.blocked_by_id)
        if not blocking_task:
            raise HTTPException(status_code=400, detail="Blocking task not found")
            
    db_task = crud.update_task(db, task_id=task_id, task=task)
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task


@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    success = crud.delete_task(db, task_id=task_id)
    if not success:
        raise HTTPException(status_code=404, detail="Task not found")
    return {"message": "Task deleted successfully"}

