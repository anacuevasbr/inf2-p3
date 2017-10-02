with Ada.Text_IO;


package body Maps_G is

   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
   	I:Natural:=1;
   begin
   	Success:=False;
   	while I<=Max and not Success loop
   		if M.P_Array(I).Full and then M.P_Array(I).Key=Key then
   			Value:=M.P_Array(I).Value;
   			Success:=True;
   		else
   			I:=I+1;
   		end if;
   	end loop;
   
   end Get;

	procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is
                  
   	Found:Boolean:=False;
   	I:Natural:=1;
   	Done:Boolean:=False;
   	
   begin
   	while not Found and I<= Max loop
   		
   		--Si existe la clave sustituir el valor
   		if M.P_Array(I).Full and M.P_Array(I).Key=Key then
   			M.P_Array(I).Value:=Value;
   			Found:=True;
   		else
   			I:=I+1;	
   		end if;
   		
   		
   	end loop;
   	I:=1;
   	if not Found then
   		
   		while I<=Max and not done loop
   			
   			if not M.P_Array(I).Full then
   				
   				M.P_Array(I).Key:=Key;
   				M.P_Array(I).Value:=Value;
   				M.P_Array(I).Full:=True;
   				Done:=True;
   				M.Length:=M.Length+1;
   			else
   				I:=I+1;
   			end if;
   			
   		end loop;
   		
   		if I>Max then
   			raise Full_Map;
   		end if;
   	end if;
   	
   end Put;
   
   procedure Delete (M      : in out Map;
                  	Key     : in  Key_Type;
                  	Success : out Boolean) is
		
		I:Natural:=1;
   begin
   	Success:=False;
   	while not Success and I<=Max loop
   		if M.P_Array(I).Full and then M.P_Array(I).Key=Key then
   			M.P_Array(I).Full:=False;
   			M.Length:=M.Length-1;
   			Success:=True;
   		else
   			I:=I+1;
   		end if;
   	end loop;
   
   end Delete;            
   
   function Map_Length (M : Map) return Natural is
		begin
		   return M.Length;
		end Map_Length;
		
	function First (M:Map) return Cursor is
		
		I:Natural:=1;
		Found:Boolean:=False;
	begin
		while I<=Max and not Found loop
			if M.P_Array(I).Full then
				Found:=True;
			else
				I:=I+1;
			end if;
		end loop;
		
		if I>Max then
			I:=0;
		end if;
		
	return (M=>M, Element=>I);
	
	end First;
	
	procedure Next (C: in out Cursor) is
		Found:Boolean:=False;
   begin
   	C.Element:=C.Element +1;
   	while C.Element<=Max and not Found loop
   		if not C.M.P_Array(C.Element).Full then
   			C.Element:=C.Element +1;
   		else
   			Found:=True;
   		end if;
   	end loop;
   	
   	if C.Element>Max then
			C.Element:=0;
		end if;
		
   end Next;
   
   function Element (C: Cursor) return Element_Type is
   begin
      if C.Element /= 0 then
         return (Key   => C.M.P_Array(C.Element).Key,
                 Value => C.M.P_Array(C.Element).Value);
      else
         raise No_Element;
      end if;
   end Element;
   
   function Has_Element (C: Cursor) return Boolean is
   begin
      if C.Element/=0 then
         return True;
      else
         return False;
      end if;
   end Has_Element;


end Maps_G;
