with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Server_Handlers;

procedure Chat_Server_2 is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
   package ACL renames Ada.Command_Line;
   package CM renames Chat_Messages;
   use type ASU.Unbounded_String;
	use type CM.Message_Type;

   Server_EP: LLU.End_Point_Type;

   Request: ASU.Unbounded_String;
   Reply: ASU.Unbounded_String := ASU.To_Unbounded_String ("¡Bienvenido!");
   Usage_Error:Exception;
   C: Character;
   Max_Limit:Exception;
   

begin

   -- construye un End_Point en una dirección y puerto concretos
   Server_EP := LLU.Build (LLU.To_IP(LLU.Get_Host_Name), 
									Integer'Value(ACL.Argument(1)));


   -- se ata al End_Point para poder recibir en él
   LLU.Bind (Server_EP, Server_Handlers.Server_Handler'Access);
   
   if Integer'Value(ACL.Argument(2))<2 or Integer'Value(ACL.Argument(2))>50 then
   	raise Max_Limit;
   end if;

	loop
      Ada.Text_IO.Get_Immediate (C);
      if C = 'l' or C = 'L' then
         Server_Handlers.Print_ACM;
      elsif C='O' or C='o' then
      	Server_Handlers.Print_OCM;
      
      end if;
   end loop;

	--LLU.Finalize;

exception
	when Usage_Error =>
		Ada.Text_IO.Put_Line("Usage: ./chat_server_2 <port> <max client>");
		LLU.Finalize;
	when Max_Limit =>
		Ada.Text_IO.Put_Line("The number of active clients must be between 2 and 50");
		LLU.Finalize;
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Server_2;
