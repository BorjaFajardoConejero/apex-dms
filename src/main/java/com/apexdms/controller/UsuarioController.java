package com.apexdms.controller;

import com.apexdms.model.Usuario;
import com.apexdms.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public String listar(Model model) {
        model.addAttribute("usuarios", usuarioService.listarTodos());
        return "usuarios/lista";
    }

    @GetMapping("/{id}")
    public String detalle(@PathVariable Long id, Model model, RedirectAttributes ra) {
        return usuarioService.buscarPorId(id)
                .map(u -> {
                    model.addAttribute("usuario", u);
                    return "usuarios/detalle";
                })
                .orElseGet(() -> {
                    ra.addFlashAttribute("error", "Usuario no encontrado.");
                    return "redirect:/usuarios";
                });
    }

    @GetMapping("/nuevo")
    public String mostrarFormularioNuevo(Model model) {
        model.addAttribute("usuario", new Usuario());
        model.addAttribute("roles", usuarioService.listarRoles());
        model.addAttribute("esNuevo", true);
        return "usuarios/formulario";
    }

    @PostMapping("/guardar")
    public String guardar(@Valid @ModelAttribute("usuario") Usuario usuario,
                          BindingResult result,
                          @RequestParam("rawPassword") String rawPassword,
                          @RequestParam("rolId") Long rolId,
                          Model model,
                          RedirectAttributes ra) {
        if (result.hasErrors() || rawPassword == null || rawPassword.length() < 6) {
            if (rawPassword == null || rawPassword.length() < 6) {
                model.addAttribute("passwordError", "La contraseña debe tener al menos 6 caracteres.");
            }
            model.addAttribute("roles", usuarioService.listarRoles());
            model.addAttribute("esNuevo", true);
            return "usuarios/formulario";
        }
        try {
            usuarioService.crearUsuario(usuario, rawPassword, rolId);
            ra.addFlashAttribute("exito", "Usuario creado correctamente.");
            return "redirect:/usuarios";
        } catch (IllegalArgumentException e) {
            model.addAttribute("error", e.getMessage());
            model.addAttribute("roles", usuarioService.listarRoles());
            model.addAttribute("esNuevo", true);
            return "usuarios/formulario";
        }
    }

    @GetMapping("/editar/{id}")
    public String mostrarFormularioEditar(@PathVariable Long id, Model model, RedirectAttributes ra) {
        return usuarioService.buscarPorId(id)
                .map(u -> {
                    model.addAttribute("usuario", u);
                    model.addAttribute("roles", usuarioService.listarRoles());
                    model.addAttribute("esNuevo", false);
                    return "usuarios/formulario";
                })
                .orElseGet(() -> {
                    ra.addFlashAttribute("error", "Usuario no encontrado.");
                    return "redirect:/usuarios";
                });
    }

    @PostMapping("/actualizar/{id}")
    public String actualizar(@PathVariable Long id,
                             @Valid @ModelAttribute("usuario") Usuario usuario,
                             BindingResult result,
                             @RequestParam(value = "rawPassword", required = false) String rawPassword,
                             @RequestParam("rolId") Long rolId,
                             Model model,
                             RedirectAttributes ra) {
        if (result.hasErrors()) {
            model.addAttribute("roles", usuarioService.listarRoles());
            model.addAttribute("esNuevo", false);
            return "usuarios/formulario";
        }
        usuarioService.actualizarUsuario(id, usuario, rawPassword, rolId);
        ra.addFlashAttribute("exito", "Usuario actualizado correctamente.");
        return "redirect:/usuarios";
    }

    @PostMapping("/baja/{id}")
    public String bajaLogica(@PathVariable Long id, RedirectAttributes ra) {
        usuarioService.bajaLogica(id);
        ra.addFlashAttribute("exito", "Usuario dado de baja lógica correctamente.");
        return "redirect:/usuarios";
    }

    @PostMapping("/reactivar/{id}")
    public String reactivar(@PathVariable Long id, RedirectAttributes ra) {
        usuarioService.reactivarUsuario(id);
        ra.addFlashAttribute("exito", "Usuario reactivado correctamente.");
        return "redirect:/usuarios";
    }
}
