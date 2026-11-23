# Apex DMS – Dealer Management System (Cloud SaaS)
**Asignatura:** Proyecto de Ingeniería del Software (47GIIN) – Universidad Internacional de Valencia (VIU)  
**Autor:** Borja Fajardo Conejero | **Metodología:** Single Scrum  
**Estado actual:** Cierre del Sprint 1 (`HU-01` a `HU-05`)

## Contenido del Sprint 1
- **HU-01:** Arquitectura en 3 capas (MVC) y Modelo de Datos completo en 3FN (`database/apex_dms_schema_3fn.sql`, 15 entidades CRUD).
- **HU-02:** Modelado de interfaces al 50% y diseño de reportes (`docs/HU02_Wireframes_50_porciento_y_Reportes.html`).
- **HU-03:** Especificación técnica de Auditoría (Logs) y Resguardos (Backups) (`docs/HU03_Especificacion_Logs_y_Backups.md`).
- **HU-04:** CRUD completo de Usuarios y Perfiles funcionales (`/usuarios`, Spring MVC + JPA + Thymeleaf + Bootstrap 5).
- **HU-05:** Autenticación con BCrypt y Control de Acceso Basado en Roles (`ROLE_ADMIN`, `ROLE_ASESOR`, `ROLE_MECANICO`).

## Requisitos previos e instalación (Eclipse / XAMPP / Maven)
1. Tener instalado **JDK 17+**, **Maven 3.9+** y **MySQL 8** (por ejemplo, arrancando MySQL desde **XAMPP**).
2. Ejecutar el script `database/apex_dms_schema_3fn.sql` en phpMyAdmin o MySQL Workbench.
3. Ajustar usuario/contraseña de MySQL en `src/main/resources/application.properties` si es necesario.
4. En **Eclipse IDE**: `File > Import > Maven > Existing Maven Projects` y seleccionar esta carpeta.
5. Ejecutar `ApexDmsApplication.java` (o por terminal `mvn spring-boot:run`) y abrir `http://localhost:8080/login`.

## Credenciales de prueba precargadas (DataInitializer)
| Perfil | Usuario | Contraseña | Acceso |
| :--- | :--- | :--- | :--- |
| Administrador / Jefe Taller | `admin` | `admin123` | Acceso total (incluye `/usuarios`) |
| Asesor de Servicio | `asesor` | `asesor123` | Dashboard, Clientes/Vehículos/Reportes (bloqueado `/usuarios`) |
| Mecánico / Operario | `mecanico` | `mecanico123` | Dashboard y Órdenes de Reparación (bloqueado `/usuarios`) |

## Ejecución de pruebas unitarias (JUnit 5)
```bash
mvn test
```
