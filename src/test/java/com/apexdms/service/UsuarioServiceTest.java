package com.apexdms.service;

import com.apexdms.model.Rol;
import com.apexdms.model.Usuario;
import com.apexdms.repository.RolRepository;
import com.apexdms.repository.UsuarioRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UsuarioServiceTest {

    @Mock
    private UsuarioRepository usuarioRepository;
    @Mock
    private RolRepository rolRepository;
    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private UsuarioService usuarioService;

    @Test
    void crearUsuario_CifraPasswordYAsignaRolCorrectamente() {
        Rol rol = new Rol("ROLE_ASESOR", "Asesor");
        rol.setId(2L);

        Usuario nuevo = new Usuario();
        nuevo.setUsername("juan.perez");
        nuevo.setNombreCompleto("Juan Pérez");
        nuevo.setEmail("juan@apexdms.es");

        when(usuarioRepository.existsByUsername("juan.perez")).thenReturn(false);
        when(usuarioRepository.existsByEmail("juan@apexdms.es")).thenReturn(false);
        when(rolRepository.findById(2L)).thenReturn(Optional.of(rol));
        when(passwordEncoder.encode("claveSegura123")).thenReturn("$2a$10$hashedPassword");
        when(usuarioRepository.save(any(Usuario.class))).thenAnswer(i -> i.getArgument(0));

        Usuario guardado = usuarioService.crearUsuario(nuevo, "claveSegura123", 2L);

        assertNotNull(guardado);
        assertTrue(guardado.getActivo());
        assertEquals("$2a$10$hashedPassword", guardado.getPasswordHash());
        assertEquals("ROLE_ASESOR", guardado.getRol().getNombre());
        verify(usuarioRepository, times(1)).save(any(Usuario.class));
    }

    @Test
    void bajaLogica_DesactivaUsuarioSinBorradoFisico() {
        Usuario existente = new Usuario();
        existente.setId(1L);
        existente.setActivo(true);

        when(usuarioRepository.findById(1L)).thenReturn(Optional.of(existente));

        usuarioService.bajaLogica(1L);

        assertFalse(existente.getActivo());
        verify(usuarioRepository, times(1)).save(existente);
    }
}
