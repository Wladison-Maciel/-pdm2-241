from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import List

from models import Aluno, SessionLocal

app = FastAPI()

class AlunoCreate(BaseModel):
    nome: str
    idade: int
    curso: str

class AlunoUpdate(BaseModel):
    nome: str
    idade: int
    curso: str

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/criar_aluno/", response_model=AlunoCreate)
def criar_aluno(aluno: AlunoCreate, db: Session = Depends(get_db)):
    db_aluno = Aluno(nome=aluno.nome, idade=aluno.idade, curso=aluno.curso)
    db.add(db_aluno)
    db.commit()
    db.refresh(db_aluno)
    return db_aluno

@app.get("/listar_alunos/", response_model=List[AlunoCreate])
def listar_alunos(db: Session = Depends(get_db)):
    return db.query(Aluno).all()

@app.get("/listar_um_aluno/{aluno_id}", response_model=AlunoCreate)
def listar_um_aluno(aluno_id: int, db: Session = Depends(get_db)):
    aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if aluno is None:
        raise HTTPException(status_code=404, detail="Aluno não encontrado")
    return aluno

@app.put("/atualizar_aluno/{aluno_id}", response_model=AlunoCreate)
def atualizar_aluno(aluno_id: int, aluno: AlunoUpdate, db: Session = Depends(get_db)):
    db_aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if db_aluno is None:
        raise HTTPException(status_code=404, detail="Aluno não encontrado")
    db_aluno.nome = aluno.nome
    db_aluno.idade = aluno.idade
    db_aluno.curso = aluno.curso
    db.commit()
    db.refresh(db_aluno)
    return db_aluno

@app.delete("/excluir_aluno/{aluno_id}")
def excluir_aluno(aluno_id: int, db: Session = Depends(get_db)):
    db_aluno = db.query(Aluno).filter(Aluno.id == aluno_id).first()
    if db_aluno is None:
        raise HTTPException(status_code=404, detail="Aluno não encontrado")
    db.delete(db_aluno)
    db.commit()
    return {"detail": "Aluno excluído com sucesso"}
