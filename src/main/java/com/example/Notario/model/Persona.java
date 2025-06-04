package com.example.Notario.model;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "personas")
public class Persona {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String dni;
    private String nombre;
    private String primerApellido;
    private String segundoApellido;
    private String genero;
    private LocalDate fechaNacimiento;
    private String profesion;

    // Getters y setters (genera estos con tu IDE)
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getDni() { return dni; }
    public void setDni(String dni) { this.dni = dni; }
    // ... añade el resto de getters y setters
}