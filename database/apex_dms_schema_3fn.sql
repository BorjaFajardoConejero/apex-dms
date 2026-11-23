-- ============================================================================
-- APEX DMS (Dealer Management System) - MODELO DE DATOS RELACIONAL (3FN)
-- Asignatura: Proyecto de Ingeniería del Software (47GIIN) - VIU
-- Autor: Borja Fajardo Conejero | Sprint 1 (HU-01)
-- Motor: MySQL 8.x (InnoDB, UTF8MB4)
-- Cobertura: 15 entidades CRUD normalizadas en 3FN + Alertas + Auditoría
-- ============================================================================

CREATE DATABASE IF NOT EXISTS apex_dms
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE apex_dms;

-- ----------------------------------------------------------------------------
-- 1. MÓDULO DE SEGURIDAD, USUARIOS Y PERFILES (CRUD 1: HU-04 / HU-05)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS roles (
    id_rol BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(30) NOT NULL UNIQUE, -- ROLE_ADMIN, ROLE_ASESOR, ROLE_MECANICO
    descripcion VARCHAR(150) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS usuarios (
    id_usuario BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    nombre_completo VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    id_rol BIGINT NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuarios_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 2. MÓDULO DE CONFIGURACIÓN DE LA ORGANIZACIÓN (CRUD 2: HU-06)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS organizacion (
    id_organizacion BIGINT AUTO_INCREMENT PRIMARY KEY,
    razon_social VARCHAR(150) NOT NULL,
    cif VARCHAR(20) NOT NULL UNIQUE,
    direccion VARCHAR(200) NOT NULL,
    codigo_postal VARCHAR(10) NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email_contacto VARCHAR(120) NOT NULL,
    tarifa_hora_ut DECIMAL(10,2) NOT NULL DEFAULT 48.00,
    iva_defecto DECIMAL(5,2) NOT NULL DEFAULT 21.00,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 3. MÓDULO DE CLIENTES Y PARQUE DE VEHÍCULOS (CRUD 3, 4 y 8: HU-07, HU-08, HU-16)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo_cliente ENUM('PARTICULAR', 'EMPRESA') NOT NULL DEFAULT 'PARTICULAR',
    dni_cif VARCHAR(20) NOT NULL UNIQUE,
    nombre_razon_social VARCHAR(150) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(120),
    direccion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    fecha_alta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS marcas (
    id_marca BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE,
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS modelos (
    id_modelo BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_marca BIGINT NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    UNIQUE KEY uk_marca_modelo (id_marca, nombre),
    CONSTRAINT fk_modelos_marca FOREIGN KEY (id_marca) REFERENCES marcas(id_marca)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehiculos (
    id_vehiculo BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cliente BIGINT NOT NULL,
    id_modelo BIGINT NOT NULL,
    matricula VARCHAR(15) NOT NULL UNIQUE,
    vin VARCHAR(17) NOT NULL UNIQUE,
    anio_matriculacion SMALLINT NOT NULL,
    kilometraje_actual INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_vehiculos_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_vehiculos_modelo FOREIGN KEY (id_modelo) REFERENCES modelos(id_modelo)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 4. MÓDULO DE CATÁLOGO TÉCNICO Y SERVICIOS (CRUD 5 y 9: HU-09, HU-17)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS familias_servicio (
    id_familia BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS servicios (
    id_servicio BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_familia BIGINT NOT NULL,
    codigo_operacion VARCHAR(30) NOT NULL UNIQUE,
    descripcion VARCHAR(180) NOT NULL,
    unidades_tiempo DECIMAL(6,2) NOT NULL, -- UT (ej. 1.50 horas)
    precio_base DECIMAL(10,2) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_servicios_familia FOREIGN KEY (id_familia) REFERENCES familias_servicio(id_familia)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 5. MÓDULO DE AGENDA Y CITAS PREVIAS (CRUD 10: HU-18)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS citas (
    id_cita BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_cliente BIGINT NOT NULL,
    id_vehiculo BIGINT NOT NULL,
    id_asesor BIGINT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    motivo_visita VARCHAR(255) NOT NULL,
    estado ENUM('PENDIENTE', 'CONFIRMADA', 'ATENDIDA', 'CANCELADA') NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT fk_citas_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_citas_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    CONSTRAINT fk_citas_asesor FOREIGN KEY (id_asesor) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 6. MÓDULO DE ALMACÉN BÁSICO Y PROVEEDORES (CRUD 11, 12 y 13: HU-19, HU-20, HU-21)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS categorias_recambio (
    id_categoria BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion VARCHAR(200),
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS proveedores (
    id_proveedor BIGINT AUTO_INCREMENT PRIMARY KEY,
    cif VARCHAR(20) NOT NULL UNIQUE,
    razon_social VARCHAR(150) NOT NULL,
    telefono VARCHAR(20),
    email VARCHAR(120),
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recambios (
    id_recambio BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_categoria BIGINT NOT NULL,
    id_proveedor BIGINT NOT NULL,
    referencia VARCHAR(50) NOT NULL UNIQUE,
    denominacion VARCHAR(160) NOT NULL,
    precio_coste DECIMAL(10,2) NOT NULL,
    precio_venta DECIMAL(10,2) NOT NULL,
    stock_actual INT NOT NULL DEFAULT 0,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_recambios_categoria FOREIGN KEY (id_categoria) REFERENCES categorias_recambio(id_categoria),
    CONSTRAINT fk_recambios_proveedor FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 7. MÓDULO DE ÓRDENES DE REPARACIÓN - CIRCUITO OPERATIVO (CRUD 6 y 7: HU-10, HU-11)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS ordenes_reparacion (
    id_or BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero_or VARCHAR(25) NOT NULL UNIQUE,
    id_vehiculo BIGINT NOT NULL,
    id_asesor BIGINT NOT NULL,
    id_mecanico BIGINT NULL,
    km_entrada INT NOT NULL,
    sintomas_cliente TEXT NOT NULL,
    estado ENUM('ABIERTA', 'EN_DIAGNOSTICO', 'EN_REPARACION', 'FINALIZADA', 'ENTREGADA', 'ANULADA') NOT NULL DEFAULT 'ABIERTA',
    fecha_apertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME NULL,
    base_imponible DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    porcentaje_iva DECIMAL(5,2) NOT NULL DEFAULT 21.00,
    total_or DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_or_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    CONSTRAINT fk_or_asesor FOREIGN KEY (id_asesor) REFERENCES usuarios(id_usuario),
    CONSTRAINT fk_or_mecanico FOREIGN KEY (id_mecanico) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lineas_or (
    id_linea BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_or BIGINT NOT NULL,
    id_servicio BIGINT NULL,
    id_recambio BIGINT NULL,
    descripcion VARCHAR(200) NOT NULL,
    cantidad_ut DECIMAL(8,2) NOT NULL DEFAULT 1.00,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_linea_or FOREIGN KEY (id_or) REFERENCES ordenes_reparacion(id_or) ON DELETE CASCADE,
    CONSTRAINT fk_linea_servicio FOREIGN KEY (id_servicio) REFERENCES servicios(id_servicio),
    CONSTRAINT fk_linea_recambio FOREIGN KEY (id_recambio) REFERENCES recambios(id_recambio)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 8. MÓDULO DE FACTURACIÓN Y COBROS (CRUD 14 y 15: HU-22, HU-23)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS formas_pago (
    id_forma_pago BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(60) NOT NULL UNIQUE, -- Efectivo, Tarjeta, Transferencia
    activo BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS facturas (
    id_factura BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero_factura VARCHAR(30) NOT NULL UNIQUE,
    id_or BIGINT NOT NULL UNIQUE,
    id_forma_pago BIGINT NOT NULL,
    fecha_emision DATE NOT NULL,
    base_imponible DECIMAL(10,2) NOT NULL,
    cuota_iva DECIMAL(10,2) NOT NULL,
    total_factura DECIMAL(10,2) NOT NULL,
    estado_cobro ENUM('PENDIENTE', 'PAGADA', 'ANULADA') NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT fk_facturas_or FOREIGN KEY (id_or) REFERENCES ordenes_reparacion(id_or),
    CONSTRAINT fk_facturas_fp FOREIGN KEY (id_forma_pago) REFERENCES formas_pago(id_forma_pago)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- 9. PROCESO AUTOMATIZADO AUTÓNOMO (HU-12) Y AUDITORÍA DE LOGS (HU-03 / HU-24)
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS alertas_mantenimiento (
    id_alerta BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_vehiculo BIGINT NOT NULL,
    id_or_origen BIGINT NULL,
    motivo_alerta VARCHAR(200) NOT NULL,
    fecha_generacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    fecha_recomendada DATE NOT NULL,
    estado ENUM('PENDIENTE', 'CONTACTADO', 'CITADO', 'DESCARTADA') NOT NULL DEFAULT 'PENDIENTE',
    CONSTRAINT fk_alerta_vehiculo FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
    CONSTRAINT fk_alerta_or FOREIGN KEY (id_or_origen) REFERENCES ordenes_reparacion(id_or)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
    id_log BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_usuario BIGINT NULL,
    username VARCHAR(50) NOT NULL,
    accion VARCHAR(40) NOT NULL, -- LOGIN, CREATE, UPDATE, DELETE, STATE_CHANGE
    entidad VARCHAR(60) NOT NULL,
    id_registro VARCHAR(40),
    detalle TEXT,
    ip_origen VARCHAR(45),
    fecha_evento TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario)
) ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- DATOS SEMILLA INICIALES (ROLES BÁSICOS)
-- ----------------------------------------------------------------------------
INSERT IGNORE INTO roles (nombre, descripcion) VALUES
('ROLE_ADMIN', 'Administrador / Jefe de Taller con acceso total'),
('ROLE_ASESOR', 'Asesor de Servicio: recepción, clientes, vehículos, OR y reportes'),
('ROLE_MECANICO', 'Mecánico / Operario: consulta e imputación de trabajos en OR asignadas');
