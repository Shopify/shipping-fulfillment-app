alert('here');
var button = $('.btn btn-danger');
var newButton = $('<input type="submit" class="btn btn-success" value="Manage with Shipwire"/>');
var container = button.parent;
button.remove();
container.append(newButton);