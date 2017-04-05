class Component extends React.Component
  R: React.DOM
  changed: (event) ->
    (proxy) => @setState "#{event}": proxy.target.value

class HelloMessage extends Component
  @F: React.createFactory(@)
  render: () ->
    @R.div null, "Hello #{@props.name}"

class AddProject extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @state = id: props.id, name: '', priority: 'high'
  render: () ->
    @R.form className: "add-project", name: "adp",
      @R.input name: "id", type: "text", hidden: "true", value: @state.id
      @R.input name: "name", type: "text", onChange: @changed('name'), value: @state.name
      @R.select name: "priority", onChange: @changed('priority'), value: @state.priority,
        @R.option value: "low", "Low"
        @R.option value: "medium", "Medium"
        @R.option value: "high", "High"

class MainWidget extends Component
  @F: React.createFactory(@)
  render: () ->
    @R.div null,
      HelloMessage.F name: "Clouds"
      AddProject.F id: "test"

ReactDOM.render MainWidget.F(), document.getElementById("main")
