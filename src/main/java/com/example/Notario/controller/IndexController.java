package com.example.Notario.controller;

import com.example.Notario.model.Persona;
import com.example.Notario.repository.PersonaRepository;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class IndexController {

    private final PersonaRepository personaRepository;

    public IndexController(PersonaRepository personaRepository) {
        this.personaRepository = personaRepository;
    }

    @GetMapping("/esp")
    public String index1() {

        return "esp";
    }

    @GetMapping("/extr")
    public String index2() {

        return "extr";
    }

    @PostMapping("/guardar-esp")
    public String guardarEspanol(Persona persona) {
        personaRepository.save(persona);
        return "redirect:/confirmacion";
    }
}