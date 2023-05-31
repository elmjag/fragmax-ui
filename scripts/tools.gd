static func get_proc_tools():
    return ["EDNA_proc", "XIA2/DIALS", "XIA2/XDS", "XDSAPP"]


static func is_proc_tool(tool_name):
    return tool_name in get_proc_tools()
