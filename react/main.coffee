class Component extends React.Component
  R: React.DOM
  changed: (event) ->
    (proxy) => @setState "#{event}": proxy.target.value

class HelloMessage extends Component
  R = React.DOM
  @F: React.createFactory(@)
  render: () ->
    R.div null, "Hello #{@props.name}"

class Projects
  constructor: () ->
    @values = {}
    @keys = []
    @listeners = []
  push: (key, object) ->
    if !@values[key]?
      @keys.push(key)
    @values[key] = object
    for i from @listeners
      i(@get())
  get: (key) ->
    if key?
      @values[key]
    else
      @values[key] for key from @keys when @values[key]?
  register: (listener) ->
    @listeners.push(listener)

class ProjectList extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @projects = props.projects
    @state = projects: @projects.get()
    @projects.register((value) => @setState projects: value)
  render: () ->
    @R.table className: 'project-list',
      @R.thead null,
        @R.tr null,
          @R.th null, "id"
          @R.th null, "name"
          @R.th null, "priority"
      @R.tbody null,
        for project from @state.projects
          @R.tr className: 'project', key: project.id,
            @R.td null, project.id
            @R.td null, project.name
            @R.td null, project.priority

class AddProject extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @state = id: props.id, name: '', priority: 'high'
    @projects = props.projects
  submit: (e) =>
    e.preventDefault()
    @projects.push(@state.id, id: @state.id, name: @state.name, priority: @state.priority)
  render: () ->
    @R.form className: "add-project", onSubmit: this.submit,
      @R.input name: "id", type: "text", hidden: "true", value: @state.id, readOnly: true
      @R.input name: "name", type: "text", onChange: @changed('name'), value: @state.name
      @R.select name: "priority", onChange: @changed('priority'), value: @state.priority,
        @R.option value: "low", "Low"
        @R.option value: "medium", "Medium"
        @R.option value: "high", "High"
      @R.input type: "submit"

class MainWidget extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @projects = new Projects
  render: () ->
    @R.div null,
      HelloMessage.F name: "Clouds"
      ProjectList.F projects: @projects
      AddProject.F projects: @projects, id: "test"

ReactDOM.render MainWidget.F(), document.getElementById("main")
