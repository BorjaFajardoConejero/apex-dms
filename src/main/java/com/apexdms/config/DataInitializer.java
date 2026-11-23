package com.apexdms.config;

import com.apexdms.model.Rol;
import com.apexdms.model.Usuario;
import com.apexdms.repository.RolRepository;
import com.apexdms.repository.UsuarioRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class DataInitializer implements CommandLineRunner {

    private final RolRepository rolRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public DataInitializer(RolRepository rolRepository,
                           UsuarioRepository usuarioRepository,
                           PasswordEncoder passwordEncoder) {
        this.rolRepository = rolRepository;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        Rol adminRol = rolRepository.findByNombre("ROLE_ADMIN")
                .orElseGet(() -> rolRepository.save(new Rol("ROLE_ADMIN", "Administrador / Jefe de Taller")));
        Rol asesorRol = rolRepository.findByNombre("ROLE_ASESOR")
                .orElseGet(() -> rolRepository.save(new Rol("ROLE_ASESOR", "Asesor de Servicio")));
        Rol mecanicoRol = rolRepository.findByNombre("ROLE_MECANICO")
                .orElseGet(() -> rolRepository.save(new Rol("ROLE_MECANICO", "Mecánico / Operario")));

        crearUsuarioSiNoExiste("admin", "admin123", "Borja Fajardo (Jefe de Taller)", "admin@apexdms.es", adminRol);
        crearUsuarioSiNoExiste("asesor", "asesor123", "Laura Gómez (Asesora de Servicio)", "asesor@apexdms.es", asesorRol);
        crearUsuarioSiNoExiste("mecanico", "mecanico123", "Carlos Ruiz (Técnico Mecánico)", "mecanico@apexdms.es", mecanicoRol);
    }

    private void crearUsuarioSiNoExiste(String username, String password, String nombre, String email, Rol rol) {
        if (!usuarioRepository.existsByUsername(username)) {
            Usuario u = new Usuario();
            u.setUsername(username);
            u.setPasswordHash(passwordEncoder.encode(password));
            u.setNombreCompleto(nombre);
            u.setEmail(email);
            u.setRol(rol);
            u.setActivo(true);
            usuarioRepository.save(u);
        }
    }
}
