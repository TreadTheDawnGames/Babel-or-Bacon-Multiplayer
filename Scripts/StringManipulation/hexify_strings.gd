class_name Hexifier


static func hexify_ip(ip : String) -> String:
	var result : String = ""
	
	var split_ip := ip.split(".")
	if(split_ip.size() > 4):
		printerr("Error colorizing IP: too many '.'s")
	var ip_ints = [0,0,0,0]
	var i = 0
	for num in split_ip:
		ip_ints[i] = int(num)
		i+=1
	
	for num in ip_ints:
		result += hexify(num)
	
	@warning_ignore("integer_division")
	result = result.insert(result.length()/2, "-")
	
	return result

static func hexify(num : int) -> String:
	var hex_string =  "%2X".to_upper() % num
	
	var replaced : String = hex_string
	for i in 10:
		match i:
			0: 
				replaced = replaced.replace(str(i), "G")
			1: 
				replaced = replaced.replace(str(i), "H")
			2: 
				replaced = replaced.replace(str(i), "I")
			3: 
				replaced = replaced.replace(str(i), "J")
			4: 
				replaced = replaced.replace(str(i), "K")
			5: 
				replaced = replaced.replace(str(i), "L")
			6: 
				replaced = replaced.replace(str(i), "M")
			7: 
				replaced = replaced.replace(str(i), "N")
			8: 
				replaced = replaced.replace(str(i), "O")
			9: 
				replaced = replaced.replace(str(i), "P")
	replaced = replaced.replace(" ", "G")
	return replaced

static func unhexify(hex : String) -> String:
	
	var replaced : String = hex.replace("-", "")
	replaced = replaced.replace(" ", "0")
	for i in 10:
		match i:
			0: 
				replaced = replaced.replace("G", str(i))
			1: 
				replaced = replaced.replace("H", str(i))
			2: 
				replaced = replaced.replace("I", str(i))
			3: 
				replaced = replaced.replace("J", str(i))
			4: 
				replaced = replaced.replace("K", str(i))
			5: 
				replaced = replaced.replace("L", str(i))
			6: 
				replaced = replaced.replace("M", str(i))
			7: 
				replaced = replaced.replace("N", str(i))
			8: 
				replaced = replaced.replace("O", str(i))
			9: 
				replaced = replaced.replace("P", str(i))
	
	var ip_strs = ["","","",""]
	var i = 0
	for strs in ip_strs:
		ip_strs[i] = replaced.substr(0,2)
		replaced = replaced.erase(0,2)
		i+=1
		print(strs)
	
	var out_str = ""
	for strs in ip_strs:
		out_str += str(strs.hex_to_int()) + "."
	
	out_str = out_str.erase(out_str.length()-1)
	
	return out_str
