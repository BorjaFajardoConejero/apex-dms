# Especificación Técnica de Requisitos No Funcionales: Auditoría (Logs) y Resguardos (Backups)
**Proyecto:** Apex DMS (Dealer Management System)  
**Historia de Usuario:** HU-03 (Sprint 1) | **Autor:** Borja Fajardo Conejero

## 1. Módulo de Auditoría del Sistema (Logs de Actividad)
Con el objetivo de garantizar la trazabilidad, el control interno y la no repudiación de las operaciones críticas en la plataforma SaaS, se especifica un mecanismo de auditoría transversal basado en **Spring AOP (Aspect-Oriented Programming)** y persistido en la tabla `audit_logs` de MySQL:

* **Eventos auditados:**
  1. Autenticación: inicios de sesión exitosos (`LOGIN_OK`), intentos fallidos (`LOGIN_FAIL`) y cierres de sesión (`LOGOUT`).
  2. Operaciones CRUD sensibles: altas, modificaciones y bajas lógicas sobre `usuarios`, `organizacion`, `clientes`, `vehiculos` y `ordenes_reparacion`.
  3. Transiciones de estado de Órdenes de Reparación (p. ej., de `EN_REPARACION` a `FINALIZADA` o `ANULADA`).
* **Estructura persistida (`audit_logs`):** `id_log`, `id_usuario`, `username`, `accion`, `entidad`, `id_registro`, `detalle` (valores clave antes/después en JSON), `ip_origen` y `fecha_evento`.
* **Inmutabilidad:** El usuario de base de datos de la aplicación solo dispondrá de permisos `INSERT` y `SELECT` sobre `audit_logs` (sin `UPDATE` ni `DELETE`), evitando la manipulación de registros históricos.

## 2. Política y Arquitectura de Resguardos (Backups)
Para proteger la continuidad operativa del taller frente a fallos de hardware, corrupción de datos o errores humanos:

* **Estrategia de copias (Regla 3-2-1 adaptada a Cloud):**
  * **Backup Diario Automatizado (03:00 CET):** Ejecución desatendida mediante tarea programada (`cron` / *GitHub Actions* o servicio gestionado del proveedor cloud) usando `mysqldump --single-transaction --routines --triggers apex_dms | gzip > apex_dms_YYYYMMDD.sql.gz`.
  * **Retención:** 7 copias diarias, 4 copias semanales (domingos) y 3 copias mensuales cifradas con AES-256 en almacenamiento externo de objetos (S3 / Backblaze / repositorio privado de respaldos).
* **Plan de Restauración y Verificación (RPO / RTO):**
  * **RPO (Recovery Point Objective):** Máximo 24 horas (pérdida máxima de datos ante desastre).
  * **RTO (Recovery Time Objective):** Inferior a 2 horas mediante script de restauración automatizada (`gunzip < backup.sql.gz | mysql -u root apex_dms`).
  * **Pruebas de integridad:** Restauración mensual en un entorno *staging* de prueba para verificar la validez real del volcado SQL.
