DELIMITER $$
  -- Creating Procedure to create the tmp audit detail
  CREATE PROCEDURE ADD_TMP_AUDIT_DETAIL(area INT,pos INT, sup INT, user INT, month INT, point_id INT, state_a INT)
  BEGIN
		DECLARE audit_id INT;
		DECLARE week INT;
		DECLARE fails INT;
		DECLARE passes INT;
		DECLARE result DOUBLE;

		-- Setting variables
		SET audit_id = (SELECT Id_Auditoria FROM auditorias_tmp WHERE User_ID = user AND Area_ID = area);
		SET week = (SELECT Semana FROM auditorias WHERE Mes = month ORDER BY Id_Auditoria DESC LIMIT 1) + 1;


		IF audit_id > 0 THEN
			-- Inserting details
			INSERT INTO detalle_auditoria_tmp(Nro_auditoria, Posicion_id, Supervisor, User_ID, Punto_Auditado, Estado)
			VALUES(audit_id, pos, sup, user, point_id, state_a);

			-- Setting counting
			SET fails = (SELECT COUNT(Estado) FROM detalle_auditoria_tmp WHERE Estado = 0 AND User_ID = user);
			SET passes = (SELECT COUNT(Estado) FROM detalle_auditoria_tmp WHERE Estado = 1 AND User_ID = user);

			-- Updating audit table
			UPDATE auditorias_tmp a SET a.Pasa = passes, a.Falla = fails WHERE a.User_ID = User_ID AND a.Area_ID = area;
		ELSE
			-- Creating tmp audit
			INSERT INTO auditorias_tmp(Supervisor_ID, User_ID, Fecha, Semana, Mes, Area_ID, Pasa, Falla, Resultado, Status)
			VALUES (sup, user, NOW(), week, month, area,0,0,0,1);

			-- Updating audit id
			SET audit_id = (SELECT Id_Auditoria FROM auditorias_tmp WHERE User_ID = user);

			-- Inserting details
			INSERT INTO detalle_auditoria_tmp(Nro_auditoria, Posicion_id, Supervisor, User_ID, Punto_Auditado, Estado)
			VALUES(audit_id, pos, sup, user, point_id, state_a);

			-- Setting counting
			SET fails = (SELECT COUNT(Estado) FROM detalle_auditoria_tmp WHERE Estado = 0 AND User_ID = user);
			SET passes = (SELECT COUNT(Estado) FROM detalle_auditoria_tmp WHERE Estado = 1 AND User_ID = user);

			-- Updating audit table
			UPDATE auditorias_tmp a SET a.Pasa = passes, a.Falla = fails WHERE a.User_ID = User_ID AND a.Area_ID = area;
		END IF;

  END;$$
DELIMITER ;