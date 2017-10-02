with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Gnat.Calendar.Time_IO;
with Ada.Exceptions;


package body Server_Handlers is

   
   package CM renames Chat_Messages;
   use type ASU.Unbounded_String;
	use type CM.Message_Type;
	use type Ada.Calendar.Time;
	use type LLU.End_Point_Type;
	
	
	procedure Send_To_All(List:ACM.Map; P_Buffer: access LLU.Buffer_Type;
								 Nick:ASU.Unbounded_String) is
		
		C: ACM.Cursor :=ACM.First(List);
		
		
		
		begin
			while ACM.Has_Element(C) loop
      	if ACM.Element(C).Key/=Nick then
         	LLU.Send(ACM.Element(C).Value.EP, P_Buffer);
         end if;
         ACM.Next(C);
      end loop; 
	end Send_To_All;
	
		
	procedure Max_Client_React( Nick_N:ASU.Unbounded_String;
										Client_Ep: LLU.End_Point_Type;
										P_Buffer: access LLU.Buffer_Type) is
		
		C: ACM.Cursor :=ACM.First(Active_Clients);	
		Oldest:Ada.Calendar.Time:=ACM.Element(C).Value.Last;
		Nick_O:ASU.Unbounded_String:=ACM.Element(C).Key;
		Success:Boolean:=False;
		Comment:ASU.Unbounded_String;
		
	begin
		while ACM.Has_Element(C) loop
			if ACM.Element(C).Value.Last < Oldest then
				Oldest:=ACM.Element(C).Value.Last;
				Nick_O:=ACM.Element(C).Key;
			end if;
			ACM.Next(C);
		
		end loop;
		
		LLU.Reset(P_Buffer.All);					
		CM.Message_Type'Output(P_Buffer, CM.Server);
		Comment:=ASU.To_Unbounded_String(ASU.To_String(Nick_O) & 
													" banned for being idle too long");
		ASU.Unbounded_String'Output(P_Buffer,ASU.To_Unbounded_String("Server"));
		ASU.Unbounded_String'Output(P_Buffer, Comment);
		--Se llama a send to all pero como el menaje tiene que mandarse a todos
		--incluida quien va a ser expulsado se pasa como nick server ya que es
		--un nick prohibido para clientes
		Send_To_All(Active_Clients,P_Buffer, ASU.To_Unbounded_String("Server"));
		ACM.Delete(Active_clients, Nick_O, Success);
		
		if Success then
			OCM.Put(Old_Clients, Nick_O, Ada.Calendar.Clock);
			ACM.Put(Active_Clients, Nick_N,
					 (Client_EP, Ada.Calendar.Clock));
		end if;
		
	end Max_Client_React;
	
   procedure Server_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is

      Client_EP_Receive: LLU.End_Point_Type;
   	Client_EP_Handler: LLU.End_Point_Type;
      Nick  : ASU.Unbounded_String;
      Mess:CM.Message_Type;
      Comment: ASU.Unbounded_String;
      Success:Boolean:=False;
      Value:Client_Data;
      Acogido:Boolean:=False;
      Message_Type_Error:Exception;
      
      
      
   begin
      -- saca lo recibido en el buffer P_Buffer.all
      Mess:=CM.Message_Type'Input(P_Buffer);
      Case Mess is
      	when CM.Init =>
				Client_EP_Receive := LLU.End_Point_Type'Input (P_Buffer);
				Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
				Nick := ASU.Unbounded_String'Input (P_Buffer);
				
				ACM.Get(Active_Clients, Nick, Value, Success);
				
				if not Success then
				
					begin
						ACM.Put(Active_Clients, Nick,
								 (Client_EP_Handler, Ada.Calendar.Clock));
					exception
						when ACM.Full_Map =>
						
						Max_Client_React(Nick, Client_Ep_handler, P_Buffer);
					end;
							 
					LLU.Reset(P_Buffer.All);					
					CM.Message_Type'Output(P_Buffer, CM.Server);
					Comment:=ASU.To_Unbounded_String(ASU.To_String(Nick) & 
																" Joins the chat");
					ASU.Unbounded_String'Output(P_Buffer,
														 ASU.To_Unbounded_String("Server"));
					ASU.Unbounded_String'Output(P_Buffer, Comment);
					Send_To_All(Active_Clients,P_Buffer, Nick);
					Acogido:=True;
				end if;
				LLU.Reset (P_Buffer.All);
				CM.Message_Type'Output(P_Buffer, CM.Welcome);
				Boolean'Output(P_Buffer, Acogido);
				-- envía el contenido del Buffer
				LLU.Send (Client_EP_Receive, P_Buffer);
				Ada.Text_IO.Put ("INIT received from ");
				Ada.Text_IO.Put (ASU.To_String(Nick));
				if Acogido then
					Ada.Text_IO.Put_Line(": ACCEPTED");
				else
					Ada.Text_IO.Put_Line(": IGNORED. Nick already used");
				end if;
								
			when CM.Writer =>
				Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
				Nick := ASU.Unbounded_String'Input (P_Buffer);
				Comment := ASU.Unbounded_String'Input (P_Buffer);
				ACM.Get(Active_Clients, Nick, Value, Success);
				if Success and then Value.Ep = Client_EP_Handler then
					--Para actualizar la hora de actividad
					ACM.Put(Active_Clients, Nick,
							 (Client_EP_Handler, Ada.Calendar.Clock));
					Ada.Text_IO.Put_Line ("WRITER received from " & 
												 ASU.To_String(Nick) & ": "
												 & ASU.To_String(Comment));
					LLU.Reset(P_Buffer.All);					
					CM.Message_Type'Output(P_Buffer, CM.Server);
					ASU.Unbounded_String'Output(P_Buffer, Nick);
					ASU.Unbounded_String'Output(P_Buffer, Comment);
					Send_To_All(Active_Clients,P_Buffer, Nick);
				else 
					Ada.Text_IO.Put_Line ("WRITER received from " & 
												 ASU.To_String(Nick) & ": "
												 & ASU.To_String(Comment));
				end if;
					
			when CM.Logout =>
				Client_EP_Handler := LLU.End_Point_Type'Input (P_Buffer);
				Nick := ASU.Unbounded_String'Input (P_Buffer);
				ACM.Get(Active_Clients, Nick, Value, Success);
				Ada.Text_IO.Put_Line ("LOGOUT received from " & 
											 ASU.To_String(Nick));
				if Success and then Value.Ep = Client_EP_Handler then
					ACM.Delete(Active_clients, Nick, Success);
					LLU.Reset(P_Buffer.All);					
					CM.Message_Type'Output(P_Buffer, CM.Server);
					Comment:=ASU.To_Unbounded_String(ASU.To_String(Nick) & 
													" leaves the chat");
					ASU.Unbounded_String'Output(P_Buffer,
														 ASU.To_Unbounded_String("Server"));
					ASU.Unbounded_String'Output(P_Buffer, Comment);
		
					Send_To_All(Active_Clients,P_Buffer, Nick);		
					OCM.Put(Old_Clients, Nick, Value.Last);
				end if;
		
			when others =>
				raise Message_Type_Error;
			end Case;
   end Server_Handler;
   
   function Time_Image (T: Ada.Calendar.Time) return String is
	
	begin
	
		return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
	end Time_Image;
	
	function Ep_Image(Ep: LLU.End_Point_Type) 
									return String is
		
		Client_Ep:ASU.Unbounded_String;
		Ip:ASU.Unbounded_String;
		N:Integer;
		Port:ASU.Unbounded_String;
	
	begin
	
	Client_Ep:=ASU.To_Unbounded_String(LLU.Image(Ep));
	N:=ASU.Index(Client_Ep, ":");
	CLient_Ep:=ASU.Tail(CLient_Ep, ASU.Length(Client_Ep)-(N+1));
	N:=ASU.Index(Client_Ep, ",");
	Ip:=ASU.Head(Client_Ep, N-1);
	N:=ASU.Index(Client_Ep, ":");
	Port:=ASU.Tail(CLient_Ep, ASU.Length(Client_Ep)-(N+1));
	Client_Ep:=ASU.To_Unbounded_String(ASU.To_String(Ip) & ":" &
									 ASU.To_String(Port));
	
	return ASU.To_String(Client_Ep);
	
	end Ep_Image;
   
   procedure Print_ACM is
      C: ACM.Cursor :=ACM.First(Active_Clients);
      
   begin
   	Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("ACTIVE CLIENTS");
      Ada.Text_IO.Put_Line ("==============");

      while ACM.Has_Element(C) loop
      	
         Ada.Text_IO.Put_Line (ASU.To_String(ACM.Element(C).Key) & " (" &
         							Ep_Image(ACM.Element(C).Value.EP) & "): "
         							& Time_Image(ACM.Element(C).Value.Last));
         ACM.Next(C);
      end loop;
      Ada.Text_IO.New_Line;
   end Print_ACM;
   
   procedure Print_OCM is
      C: OCM.Cursor :=OCM.First(Old_Clients);
      
   begin
   	Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("OLD CLIENTS");
      Ada.Text_IO.Put_Line ("==============");

      while OCM.Has_Element(C) loop
      	
         Ada.Text_IO.Put_Line (ASU.To_String(OCM.Element(C).Key) & ": "
         							& Time_Image(OCM.Element(C).Value));
         OCM.Next(C);
      end loop;
      Ada.Text_IO.New_Line;
   end Print_OCM;


end Server_Handlers;

