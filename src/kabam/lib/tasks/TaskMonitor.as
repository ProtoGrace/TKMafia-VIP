package kabam.lib.tasks {
public class TaskMonitor {


    public function TaskMonitor() {
        super();
        this.tasks = new Vector.<Task>(0);
    }
    private var tasks:Vector.<Task>;

    public function add(task:Task):void {
        this.tasks.push(task);
        task.finished.addOnce(this.onTaskFinished);
    }

    public function has(task:Task):Boolean {
        return this.tasks.indexOf(task) != -1;
    }

    private function onTaskFinished(task:Task, isOK:Boolean, error:String = ""):void {
        this.tasks.splice(this.tasks.indexOf(task), 1);
    }
}
}
