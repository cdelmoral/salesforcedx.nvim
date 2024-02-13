local get_node_text = function(node)
	local bufnr = vim.api.nvim_get_current_buf()
	local start_row, start_col, end_row, end_col = node:range()
	local line = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)[1]
	local node_text = string.sub(line, start_col + 1, end_col)
	return node_text
end

local get_child_nodes = function(node, node_type, node_field)
	local child_nodes = {}
	for child_node, field in node:iter_children() do
		if child_node:type() == node_type and field == node_field then
			table.insert(child_nodes, child_node)
		end
	end
	return child_nodes
end

local get_matching_annotation = function(node, annotation_name)
	local modifiers = get_child_nodes(node, "modifiers", nil)[1]
	local annotations = get_child_nodes(modifiers, "annotation", nil)

	for _, annotation in ipairs(annotations) do
		local name = get_node_text(annotation:named_child(0))
		if string.lower(name) == string.lower(annotation_name) then
			return annotation
		end
	end

	return nil
end

local apex = {}

function apex.get_class_declaration_node(node)
	for child in node:root():iter_children() do
		if child:type() == "class_declaration" then
			return child
		end
	end
end

function apex.get_identifier_name(node)
	local child_node = get_child_nodes(node, "identifier", "name")[1]
	return get_node_text(child_node)
end

function apex.get_current_method_declaration_node(node)
	local current = node
	while current ~= nil and current:type() ~= "method_declaration" do
		current = current:parent()
	end

	return current
end

function apex.is_test(node)
	local istest_annotation = get_matching_annotation(node, "IsTest")
	return istest_annotation ~= nil
end

return apex
