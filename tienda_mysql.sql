-- Proyecto: Base de datos en MySQL
-- Caso práctico: inventario y ventas de una tienda
-- Ejecutar en MySQL Workbench o phpMyAdmin.

CREATE DATABASE IF NOT EXISTS tienda_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE tienda_db;

CREATE TABLE proveedores (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

CREATE TABLE clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo VARCHAR(100)
);

CREATE TABLE productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(255),
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL DEFAULT 0,
    id_proveedor INT NOT NULL,
    CONSTRAINT chk_producto_precio CHECK (precio >= 0),
    CONSTRAINT chk_producto_stock CHECK (stock >= 0),
    CONSTRAINT fk_producto_proveedor
      FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE compras (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_proveedor INT NOT NULL,
    CONSTRAINT fk_compra_proveedor
      FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);

CREATE TABLE detalle_compra (
    id_detalle_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    costo_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_compra_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_compra_costo CHECK (costo_unitario >= 0),
    CONSTRAINT fk_dc_compra FOREIGN KEY (id_compra) REFERENCES compras(id_compra),
    CONSTRAINT fk_dc_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

CREATE TABLE ventas (
    id_venta INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_cliente INT NOT NULL,
    CONSTRAINT fk_venta_cliente
      FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);

CREATE TABLE detalle_venta (
    id_detalle_venta INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    CONSTRAINT chk_venta_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_venta_precio CHECK (precio_unitario >= 0),
    CONSTRAINT fk_dv_venta FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    CONSTRAINT fk_dv_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Datos de prueba
INSERT INTO proveedores (nombre, telefono, correo) VALUES
('Distribuciones Centro', '3001112233', 'centro@example.com'),
('Tecnología del Norte', '3004445566', 'norte@example.com');

INSERT INTO clientes (nombre, telefono, correo) VALUES
('Laura Pérez', '3101234567', 'laura@example.com'),
('Carlos Gómez', '3117654321', 'carlos@example.com');

INSERT INTO productos (nombre, descripcion, precio, stock, id_proveedor) VALUES
('Teclado', 'Teclado USB', 45000.00, 20, 1),
('Mouse', 'Mouse óptico', 28000.00, 35, 1),
('Audífonos', 'Audífonos con cable', 65000.00, 12, 2),
('Memoria USB', 'Memoria USB de 64 GB', 32000.00, 25, 2);

INSERT INTO compras (id_proveedor) VALUES (1), (2);
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, costo_unitario) VALUES
(1, 1, 20, 30000.00),
(1, 2, 35, 17000.00),
(2, 3, 12, 42000.00),
(2, 4, 25, 19000.00);

INSERT INTO ventas (id_cliente) VALUES (1), (2);
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 2, 45000.00),
(1, 2, 1, 28000.00),
(2, 3, 1, 65000.00),
(2, 4, 2, 32000.00);

-- SELECT: consultar todos los productos
SELECT * FROM productos;

-- WHERE: consultar productos con precio superior a $30.000
SELECT nombre, precio, stock
FROM productos
WHERE precio > 30000;

-- GROUP BY: total vendido por producto
SELECT p.nombre, SUM(dv.cantidad) AS unidades_vendidas,
       SUM(dv.cantidad * dv.precio_unitario) AS total_vendido
FROM detalle_venta dv
JOIN productos p ON p.id_producto = dv.id_producto
GROUP BY p.id_producto, p.nombre
ORDER BY total_vendido DESC;

-- Subconsulta: productos cuyo precio supera el precio promedio
SELECT nombre, precio
FROM productos
WHERE precio > (SELECT AVG(precio) FROM productos);

-- Vista: resumen de cada venta
CREATE OR REPLACE VIEW vista_resumen_ventas AS
SELECT v.id_venta, v.fecha, c.nombre AS cliente,
       SUM(dv.cantidad * dv.precio_unitario) AS total_venta
FROM ventas v
JOIN clientes c ON c.id_cliente = v.id_cliente
JOIN detalle_venta dv ON dv.id_venta = v.id_venta
GROUP BY v.id_venta, v.fecha, c.nombre;

SELECT * FROM vista_resumen_ventas;

-- UPDATE: ejemplo de modificación de precio
UPDATE productos SET precio = 47000.00 WHERE id_producto = 1;

-- DELETE: ejemplo seguro sobre un registro de prueba.
-- Descomentar únicamente si se creó previamente un cliente temporal sin ventas:
-- DELETE FROM clientes WHERE correo = 'prueba_temporal@example.com';

-- Verificar estructura y relaciones
SHOW TABLES;
DESCRIBE productos;
