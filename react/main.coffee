R = React.DOM

class Component extends React.Component
  changed: (event) ->
    (proxy) => @setState "#{event}": proxy.target.value

class HelloMessage extends Component
  @F: React.createFactory(@)
  render: () ->
    R.div null,
      "Hello #{@props.name}"
      R.style null,
        ".table    { display: table }"
        ".thead    { display: table-header-group }"
        ".tbody    { display: table-row-group }"
        ".tfoot    { display: table-footer-group }"
        ".col      { display: table-column }"
        ".colgroup { display: table-column-group }"
        ".caption  { display: table-caption }"
        ".tr       { display: table-row }"
        ".td, .th  { display: table-cell }"

        ".mono     { font-family: monospace }"

class DefaultDict
  @factory = Object
  get: (key) ->
    if !@[key]?
      @[key] = new @constructor.factory
    return @[key]

class List
  constructor: () ->
    @values = {}
    @keys = []
    @listeners = []
  push: (key, object) ->
    if !object?
      object = key
      key = object[@constructor.key]
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

class Projects extends List
  @key = "id"

class Timeline extends List
  @key = "date"

class TimelineDict extends DefaultDict
  @factory = Timeline

class DbConnector
  @KB: 1024
  @MB: 1024*@KB
  @createGuid: () ->
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g,
      (c) ->
        r = Math.random()*16|0
        r = r&0x3|0x8 if c != 'x'
        r.toString(16)

class ProjectList extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @projects = props.projects
    @state = projects: @projects.get()
    @projects.register((value) => @setState projects: value)
  render: () ->
    R.div className: 'table project-list',
      R.div className: 'thead',
        R.div className: 'tr',
          R.span className: 'th', "id"
          R.span className: 'th', "name"
          R.span className: 'th', "priority"
          R.span className: 'th', "action"
      R.div className: 'tbody',
        for project from @state.projects
          R.div className: 'tr project', key: project.id,
            R.span className: 'td mono', project.id.substring(0,8)
            R.span className: 'td', project.name
            R.span className: 'td', project.priority
            R.span className: 'td', "edit"
      R.div className: 'tfoot',
        AddProject.F projects: @projects, id: DbConnector.createGuid()

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
    R.form className: "tr add-project", onSubmit: this.submit,
      R.span className: 'td', R.input name: "id", type: "text", value: @state.id, readOnly: true
      R.span className: 'td', R.input name: "name", type: "text", onChange: @changed('name'), value: @state.name
      R.span className: 'td', R.select name: "priority", onChange: @changed('priority'), value: @state.priority,
        R.option value: "low", "Low"
        R.option value: "medium", "Medium"
        R.option value: "high", "High"
      R.span className: 'td', R.input type: "submit"

class TimelineChart extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @timeline = props.timeline
    @projects = props.projects
    @state = timeline: []
    for p, i in @projects.get()
      t = @timeline[p.id]
      @state.timeline[i] = label: p.name, times: @convert(t.get())
      t.register((value) => @setState () -> @state.timeline[i].times = @convert(value))
  parseDate: (x) ->
    d3.timeParse("%Y-%m-%d")(x) * 1
  parseDuration: (x) ->
    # TODO: fix duration
    p = d3.timeParse("%H:%M:%S")
    p(x) - p("0:00:00")
  convert: (value) ->
    value.map (x) =>
      start = @parseDate(x.date)
      duration = @parseDuration(x.duration)
      end = start + @parseDuration("24:00:00")
      starting_time: start, ending_time: end, duration: duration
  componentDidMount: () ->
    svg = d3.select("svg").attr("width", 500).attr("height", 800)
    chart = d3.timeline().stack().tickFormat format: d3.timeFormat("%m%d"), tickTime: d3.timeDay, tickInterval: 1, tickSize: 6
    svg.datum(@state.timeline).call(chart)
  render: () ->
    R.svg null

class MainWidget extends Component
  @F: React.createFactory(@)
  constructor: (props) ->
    super(props)
    @projects = new Projects
    if props.data?.projects?
      for i from props.data.projects
        @projects.push(i)
    @timeline = new TimelineDict
    if props.data?.timeline?
      for i from props.data.timeline
        @timeline.get(i.id).push(i)
  render: () ->
    R.div null,
      HelloMessage.F name: "Clouds"
      ProjectList.F projects: @projects
      TimelineChart.F timeline: @timeline, projects: @projects

ReactDOM.render MainWidget.F(data: @data), document.getElementById("main")
