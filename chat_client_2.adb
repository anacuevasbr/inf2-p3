with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Ada.Characters.Handling;
with Client_Handlers;

procedure Chat_Client_2 is
   package LLU renames Lower_Layer_UDP;
   package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
	use type ASU.Unbounded_String;
	use type CM.Message_Type;
	
   Server_EP: LLU.End_Point_Type;
   Client_EP_Receive: LLU.End_Point_Type;
   Client_EP_Handler: LLU.End_Point_Type;
   Buffer:    aliased LLU.Buffer_Type(1024);
   Request:   ASU.Unbounded_String;
   Reply:     ASU.Unbounded_String;
   Expired : Boolean;
   Nick:     ASU.Unbounded_String;
   Mess:CM.Message_Type;
   Acogido:Boolean:=False;
   Quit:Boolean:=False;
   Comment:     ASU.Unbounded_String;
   Usage_Error:Exception;
   Unreachable: Exception;

begin
   
   Server_EP := LLU.Build(LLU.To_IP(ACL.Argument(1)), 
									  Integer'Value(ACL.Argument(2)));
	Nick:=ASU.To_Unbounded_String(Ada.Characters.Handling.To_Lower
										     ((ACL.Argument(3))));
   -- End point para recibir welcome messages
   LLU.Bind_Any(Client_EP_Receive);
   --End point para el resto de mensajes
   LLU.Bind_Any(Client_EP_Handler, Client_Handlers.Client_Handler'Access);

	--Server no es un nick valido
   if Nick /= "server" then
		LLU.Reset(Buffer);

		-- introduce el End_Point del cliente en el Buffer
		-- para que el servidor sepa dónde responder
		CM.Message_Type'Output(Buffer'Access, CM.Init);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Receive);
		LLU.End_Point_Type'Output(Buffer'Access, Client_Ep_Handler);
		ASU.Unbounded_String'Output(Buffer'Access, Nick);
	
		LLU.Send(Server_EP, Buffer'Access);

		
		LLU.Reset(Buffer);

	  
		LLU.Receive(Client_EP_Receive, Buffer'Access, 10.0, Expired);
		if Expired then
		   raise Unreachable;
		else
		   -- saca del Buffer un Unbounded_String
		   Mess:=CM.Message_Type'Input(Buffer'Access);
		   Acogido:=Boolean'Input(Buffer'Access);
		   
		   
		end if;
	end if;
	
	
	if Acogido then
		Ada.Text_IO.Put_Line("Mini-chat 2.0: Welcome " & ASU.To_String(Nick));
		Quit:=False;
		while not Quit loop
			Ada.Text_IO.Put(">>");
			Comment:=ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
			LLU.Reset(Buffer);
			
			if Comment /= ".quit" then
				CM.Message_Type'Output(Buffer'Access, CM.Writer);
   			LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
   			ASU.Unbounded_String'Output(Buffer'Access, Nick);
   			ASU.Unbounded_String'Output(Buffer'Access, Comment);
   			LLU.Send(Server_EP, Buffer'Access);
			else
				CM.Message_Type'Output(Buffer'Access, CM.Logout);
   			LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
   			ASU.Unbounded_String'Output(Buffer'Access, Nick);
   			LLU.Send(Server_EP, Buffer'Access);
   			Quit:=True;
			end if;
		end loop;
	else
		Ada.Text_IO.Put_Line("Ignored new user " & ASU.To_String(Nick) &
									", nick already used");
	end if;
   -- termina Lower_Layer_UDP
   LLU.Finalize;

exception

	when Usage_Error =>
		Ada.Text_IO.Put_Line("Usage: ./chat_client_2 <hostname> <port>" & 
									 " <nick>");
		LLU.Finalize;
		when Unreachable =>
		Ada.Text_IO.Put_Line ("Server unreachable");
		LLU.Finalize;
   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;

end Chat_Client_2;
