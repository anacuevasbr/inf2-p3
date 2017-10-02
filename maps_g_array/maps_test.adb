with Ada.Text_IO;
With Ada.Strings.Unbounded;
with Maps_G;
with Lower_Layer_UDP;
with Ada.Calendar;
with Ada.Exceptions;

procedure Maps_Test is
   package ASU  renames Ada.Strings.Unbounded;
   package ATIO renames Ada.Text_IO;
   package LLU renames Lower_Layer_UDP;
   
   type Client_Data is record
   	EP:LLU.End_Point_Type;
   	Last:Ada.Calendar.Time;
   end record;


   package Maps_Act_pck is new Maps_G (Key_Type   => ASU.Unbounded_String,
                               		  Value_Type => Client_Data,
                              		  "="        => ASU."=",
                              		  Max        =>3);

   
   

   A_Map : Maps_Act_pck.Map;

   procedure Print_Map (M : Maps_Act_pck.Map) is
      C: Maps_Act_pck.Cursor :=Maps_Act_pck.First(M);
      
   begin
   	
      Ada.Text_IO.Put_Line ("Map");
      Ada.Text_IO.Put_Line ("===");
      
		
      while Maps_Act_pck.Has_Element(C) loop
      	
         Ada.Text_IO.Put_Line (ASU.To_String(Maps_Act_pck.Element(C).Key));
         Maps_Act_pck.Next(C);
      end loop;
      
   end Print_Map;
   
   Value:Client_Data;
   Success:Boolean:=False;

begin

   ATIO.New_Line;
   Ada.Text_IO.Put_Line(Natural'Image(Maps_Act_pck.Map_Length(A_Map)));
   
   Print_Map (A_Map);
	Ada.Text_IO.Put_Line("entra en el put");
   Maps_Act_pck.Put (A_Map,
             ASU.To_Unbounded_String ("Ana"),
             (LLU.Build("127.0.0.1", 9001), Ada.Calendar.Clock));
   Ada.Text_IO.Put_Line(Natural'Image(Maps_Act_pck.Map_Length(A_Map)));
             
   Maps_Act_pck.Put (A_Map,
             ASU.To_Unbounded_String ("javi"),
             (LLU.Build("127.0.0.2", 9001), Ada.Calendar.Clock));
   Ada.Text_IO.Put_Line(Natural'Image(Maps_Act_pck.Map_Length(A_Map)));
   Maps_Act_pck.Put (A_Map,
             ASU.To_Unbounded_String ("marta"),
             (LLU.Build("127.0.0.3", 9001), Ada.Calendar.Clock));
   Ada.Text_IO.Put_Line(Natural'Image(Maps_Act_pck.Map_Length(A_Map))); 
   Maps_Act_pck.Put (A_Map,
             ASU.To_Unbounded_String ("Ana"),
             (LLU.Build("127.0.0.3", 9001), Ada.Calendar.Clock));
   Ada.Text_IO.Put_Line(Natural'Image(Maps_Act_pck.Map_Length(A_Map)));       
--	Ada.Text_IO.Put_Line("Sale del put");
--   
   Print_Map(A_Map);
	Ada.Text_IO.Put_Line(Boolean'Image(Success));
	Maps_Act_pck.Get(A_Map, ASU.To_Unbounded_String("javi"), Value, Success);
	Ada.Text_IO.Put_Line(Boolean'Image(Success));
	Maps_Act_pck.Get(A_Map, ASU.To_Unbounded_String("carlos"), Value, Success);
	Ada.Text_IO.Put_Line(Boolean'Image(Success));
	Maps_Act_pck.Delete(A_Map, ASU.To_Unbounded_String("javi"), Success);
	Print_Map(A_Map);
	Maps_Act_pck.Put (A_Map,
             ASU.To_Unbounded_String ("pablo"),
             (LLU.Build("127.0.0.3", 9001), Ada.Calendar.Clock));
   Ada.Text_IO.Put_Line(Natural'Image(Maps_Act_pck.Map_Length(A_Map)));
   Print_Map(A_Map);
  
	LLU.Finalize;
exception

   when Ex:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                            Ada.Exceptions.Exception_Name(Ex) & " en: " &
                            Ada.Exceptions.Exception_Message(Ex));
      LLU.Finalize;
end Maps_Test;
