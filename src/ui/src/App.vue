<template>
  <h1>{{ title }}</h1>
  <img src="@/assets/chorepoint.svg" width="192" height="192" />
  <h2>Do Chores. Score Points. Win prizes!?</h2>
  <button @click="settings.edit = !settings.edit">
    {{ settings.edit ? "Done editing" : "Edit chores" }}
  </button>
  <div v-if="settings.edit">
    <input
      type="text"
      v-model="newTask"
      @keyup.enter="addTask"
      placeholder="Add a new chore"
    />
    <div v-if="newTask.length > 0">
      <h3>New chore preview</h3>
      <p>{{ newTask }}</p>
    </div>
  </div>

  <div>
    You have {{ allTasks }} chore{{ allTasks !== 1 ? "s" : "" }} at the moment
  </div>
  <ol>
    <li
      v-for="chore in latest"
      :key="chore.id"
      :class="[chore.finished ? 'strikeout' : '', 'simple-class']"
    >
      {{ chore.name }}: last done {{ lastDone(chore) }}
      <span v-if="settings.edit"><button>Edit chore</button></span>
      <span v-else>
        <button @click="finishChore(chore)">Finished Chore</button>
        <select class="form-control" @change="claimChore(chore, $event)">
          <option value="" selected disabled>Worker</option>
          <option v-for="drudge in drudges" :value="drudge.id" :key="drudge.id">
            {{ drudge.nick }}
          </option>
        </select>
      </span>
      <p>{{ chore.description }}</p>
    </li>
  </ol>
  <ul>
    <li v-for="record in records" :key="record.completed">{{ record }}</li>
  </ul>
</template>

<script>
export default {
  data() {
    return {
      title: "Chorepoint",
      settings: { edit: true, group: false },
      newTask: "",
      chores: [
        {
          id: 1,
          name: "Wash dishes",
          description: "Wash a days worth of dishes, including cookware",
          shared: true,
          repeat_min: 43200,
          repeat_max: 216000,
        },
        { id: 2, name: "Build a Vue Application", finished: false },
        { id: 3, name: "Write an article about Vue JS", finished: false },
      ],
      drudges: [
        { id: 1, nick: "daddio", name: "Joshua Clayton", crew: 1, chores: 2 },
        { id: 2, nick: "Mom", name: "Amie Clayton", crew: 1, chores: null },
      ],
      crews: [{ id: 1, name: "Clayton Family", chores: [1] }],
      records: [{ chore_id: 1, completed: 1627082358034, drudge: 1 }],
    };
  },
  methods: {
    addTask() {
      if (this.newTask.length < 1) return;

      this.chores.push({
        id: this.chores.length + 1,
        name: this.newTask,
        finished: false,
      });
      this.newTask = "";
    },
    finishChore(chore) {
      this.records.push({
        chore_id: chore.id,
        completed: Date.now(),
        drudge: 1,
      });
    },
    claimChore(chore, event) {
      let drudge_id =
        event.target.options[event.target.options.selectedIndex].value;
      this.records.push({
        chore_id: chore.id,
        completed: Date.now(),
        drudge: parseInt(drudge_id),
      });
    },
    removeTask(choreId) {
      this.chores = this.chores.filter((chore) => {
        return chore.id !== choreId;
      });
    },
    lastDone(chore) {
      for (let i = this.records.length - 1; i >= 0; i--) {
        let record = this.records[i];
        if (record.chore_id === chore.id) {
          let drudge = this.drudges.find((d) => d.id === record.chore_id);
          let age = Date.now() - record.completed;
          return age + " seconds ago by " + drudge.nick;
        }
      }
      return "never";
    },
  },
  computed: {
    allTasks() {
      return this.chores.length;
    },
    latest() {
      return [...this.chores].reverse();
    },
  },
};
</script>
<style>
.strikeout {
  text-decoration: line-through;
}
</style>
