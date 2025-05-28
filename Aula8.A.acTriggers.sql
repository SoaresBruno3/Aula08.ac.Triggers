--Questão 01.

--Ao realizar um curso o aluno ganha créditos.

--Ao eliminar um curso da lista do aluno, os seus créditos totais deverão ser reduzidos.
--Construa uma Trigger chamada dbo.lost_credits que atualiza o valor de créditos de um aluno após a retirada de um curso da sua lista.

--Cria a Trigger
CREATE TRIGGER dbo.lost_credits
ON dbo.takes
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Atualiza os créditos apenas para cursos concluídos (com nota)
        UPDATE s
        SET s.tot_cred = s.tot_cred - c.credits
        FROM student s
        INNER JOIN deleted d ON s.ID = d.ID
        INNER JOIN course c ON d.course_id = c.course_id
        WHERE d.grade IS NOT NULL AND d.grade != '';
        
        -- Garante créditos não negativos
        UPDATE student
        SET tot_cred = 0
        WHERE tot_cred < 0;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        THROW;
    END CATCH;
END;

--Veirifica Créditos
SELECT ID, name, tot_cred FROM student WHERE ID = '30299';

-- Remove um curso do aluno
DELETE FROM takes WHERE ID = '30299' AND course_id = '843';

-- Verifica créditos depois
SELECT ID, name, tot_cred FROM student WHERE ID = '30299';


