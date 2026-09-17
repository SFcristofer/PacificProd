# Agent Spec: Agentforce Administrator

## Purpose
Internal assistant for CEOs Rubén and Verónica with unrestricted, full-visibility access to the same Pacific Global commercial data that "Agentforce CAM - Jenny" (`Agentforce_CAM_Jenny`) exposes to Key Account Managers — but with **all factory-name / origin-cost confidentiality restrictions removed**.

## Base
Clone of `Agentforce_CAM_Jenny` (Employee agent). Same data model, same actions, same output-format/email/Excel rules — only the confidentiality clauses are removed.

## Config
- `agent_label`: "Agentforce Administrator"
- `developer_name`: `Agentforce_Administrator`
- `agent_template` / `agent_type`: `EmployeeCopilot__AgentforceEmployeeAgent` / `AgentforceEmployeeAgent` (Employee agent, same as Jenny)
- `description`: Asistente virtual interno con acceso total y sin restricciones a la información comercial de Pacific Global, para uso de dirección (CEOs).

## Environment prerequisites
Employee agent → omit `access.default_agent_user`, `connection messaging:`, and MessagingSession-linked variables are kept only as in Jenny (they're harmless linked vars, not messaging config). No knowledge (`knowledge:`) block, so no Einstein Agent User requirement.

## Variables, language, knowledge, router, off_topic/ambiguous subagents
Identical to Jenny — no changes needed.

## Data-model rules (carried over unchanged)
- REGLA 2 Ventas (`Venta__c` → `Oportunidad__r`, aggregate vs. individual query guidance)
- REGLA 4 Facturación (`FacturaDeCliente__c` by `Cliente__c`)
- REGLA 5 Jerarquía/Planificación (`PlanificacionComercial__c` precomputed fields)
- REGLA 6 Productos vendidos (`OpportunityLineItem` fields)
- REGLA 7 Formato de respuesta (no narrar proceso interno, no IDs salvo pedido, resumen vs. detalle)
- REGLA 8 Nombres/fechas flexibles
- Notas y archivos adjuntos (`Tech_Get_Related_Notes_And_Files`)

## Changes vs. Jenny (the actual point of this agent)
1. **REGLA 1 (Account types)**: keep FABRICA vs. cliente filtering logic, but **delete** "NUNCA reveles nombres de fábricas ni costos en origen al usuario."
2. **REGLA 3 (Fábricas/Proveedores)**: keep Product2/`Fabrica__c` lookup logic, **delete** the never-reveal-factory-name/cost line.
3. **REGLA 6 (Productos)**: **delete** "NUNCA consultes ni muestres Fabrica__c, IdFabrica__c ni Nombre_Fabrica__c" — CEOs may query and see these fields.
4. **REGLA 9 (Redacción de correos)**: **delete** "Nunca incluyas... nombres de fábricas, costos en origen..." — drafts may include factory names/origin costs freely.
5. **REGLA 10 (Exportar a Excel)**: **delete** "Nunca incluyas nombres de fábricas ni costos en origen dentro del archivo exportado" — exports may include these fields.
6. **REGLAS DE ACTUACIÓN item 5** ("Nunca reveles información sobre nombres de fábricas o costos en origen"): **delete**.
7. Same deletions mirrored in the `Gestion_Actividades_CAM`-equivalent subagent (renamed `Gestion_Informacion_Administrator`): remove the "NUNCA reveles el nombre de la fábrica..." line, the "NUNCA consultes ni muestres Fabrica__c..." line, and the "Nunca incluyas nombres de fábricas..." lines in email/Excel sections.
8. System instructions intro line updated: role is CEO/dirección general (Rubén, Verónica), not CAM, with explicit note that access is unrestricted/full-visibility (no data masking).

## Actions (all reused as-is, no new implementations — Path B, existing actions)
Same 8 actions as Jenny, unchanged inputs/outputs/targets:
`GetActivityDetails`, `GetActivitiesTimeline`, `SummarizeRecord`, `QueryRecords`, `QueryRecordsWithAggregate`, `IdentifyRecordByName`, `Tech_Get_Related_Notes_And_Files`, `Tech_Export_Records_To_Excel`.

## Naming note
User wrote "Agentforce Aministrator" — treating as a typo and using "Agentforce Administrator" for both label and developer_name. Flag for confirmation.

## Out of scope
No knowledge grounding, no voice modality, no new Apex/Flow — pure clone + rule removal.
