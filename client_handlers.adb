with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;


package body Client_Handlers is

   package ASU renames Ada.Strings.Unbounded;
   package CM renames Chat_Messages;
   use type ASU.Unbounded_String;
	use type CM.Message_Type;

   procedure Client_Handler (From    : in     LLU.End_Point_Type;
                             To      : in     LLU.End_Point_Type;
                             P_Buffer: access LLU.Buffer_Type) is
      Reply    : ASU.Unbounded_String;
      Mess:CM.Message_Type;
      Nick    : ASU.Unbounded_String;
   begin
      
      Mess:=CM.Message_Type'Input(P_Buffer);
      Nick := ASU.Unbounded_String'Input(P_Buffer);
      Reply := ASU.Unbounded_String'Input(P_Buffer);
      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put(ASU.To_String(Nick) & ": ");
      Ada.Text_IO.Put_Line(ASU.To_String(Reply));

      Ada.Text_IO.Put(">> ");

   end Client_Handler;

end Client_Handlers;

