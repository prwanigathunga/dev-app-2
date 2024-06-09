package com.example.devapp.service;

import com.example.devapp.entity.Student;
import com.example.devapp.repository.StudentRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class StudentService {

    private final StudentRepository studentRepository;

    @Autowired
    public StudentService(StudentRepository studentRepository) {
        this.studentRepository = studentRepository;
    }

    @Transactional
    public Student getStudent(int id){
        return studentRepository.findById(id).orElse(null);
    }
}
