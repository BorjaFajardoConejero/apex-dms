package com.apexdms.service;

import com.apexdms.model.Rol;
import com.apexdms.model.Usuario;
import com.apexdms.repository.RolRepository;
import com.apexdms.repository.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(UsuarioRepository usuarioRepository,
                          RolRepository rolRepository,
                          PasswordEncoder passwordEncoder) {
        this.usuarioRepository = usuarioRepository;
        this.rolRepository = rolRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public List<Usuario> listarTodos() {
        return usuarioRepository.findAll();
    }

    public Optional<Usuario> buscarPorId(Long id) {
        return usuarioRepository.findById(id);
    }

    public List<Rol> listarRoles() {
        return rolRepository.findAll();
    }

    @Transactional
    public Usuario crearUsuario(Usuario usuario, String rawPassword, Long rolId) {
        if (usuarioRepository.existsByUsername(usuario.getUsername())) {
            throw new IllegalArgumentException("El nombre de usuario ya existe en el sistema.");
        }
        if (usuarioRepository.existsByEmail(usuario.getEmail())) {
            throw new IllegalArgumentException("El correo electrónico ya está registrado.");
        }
        Rol rol = rolRepository.findById(rolId)
                .orElseThrow(() -> new IllegalArgumentException("Rol no válido."));

        usuario.setRol(rol);
        usuario.setPasswordHash(passwordEncoder.encode(rawPassword));
        usuario.setActivo(true);
        return usuarioRepository.save(usuario);
    }

    @Transactional
    public Usuario actualizarUsuario(Long id, Usuario datosActualizados, String newRawPassword, Long rolId) {
        Usuario existente = usuarioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));
        Rol rol = rolRepository.findById(rolId)
                .orElseThrow(() -> new IllegalArgumentException("Rol no válido."));

        existente.setNombreCompleto(datosActualizados.getNombreCompleto());
        existente.setEmail(datosActualizados.getEmail());
        existente.setRol(rol);
        existente.setActivo(datosActualizados.getActivo());

        if (newRawPassword != null && !newRawPassword.isBlank()) {
            existente.setPasswordHash(passwordEncoder.encode(newRawPassword));
        }
        return usuarioRepository.save(existente);
    }

    @Transactional
    public void bajaLogica(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));
        usuario.setActivo(false);
        usuarioRepository.save(usuario);
    }

    @Transactional
    public void reactivarUsuario(Long id) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado."));
        usuario.setActivo(true);
        usuarioRepository.save(usuario);
    }
}
