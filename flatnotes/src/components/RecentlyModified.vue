<template>
  <div>
    <h6 class="text-center text-muted text-bold">Recently Modified</h6>

    <!-- Loading -->
    <div v-if="notes == null">
      <loading-indicator :failed="loadingFailed" />
    </div>

    <!-- No Notes -->
    <div v-else-if="notes.length == 0">
      <p class="text-center">No Notes</p>
    </div>

    <!-- Notes Loaded -->
    <div v-else>
      <p
        v-for="note in notes"
        class="text-center clickable-link mb-2"
        :key="note.title"
      >
        <a :href="note.href" @click.prevent="openNote(note.href, $event)">{{
          note.title
        }}</a>
      </p>
    </div>
  </div>
</template>

<script>
import api from "../api";
import { Note } from "../classes";
import EventBus from "../eventBus";
import LoadingIndicator from "./LoadingIndicator.vue";

export default {
  components: {
    LoadingIndicator,
  },

  data: function () {
    return {
      notes: null,
      loadingFailed: false,
    };
  },

  methods: {
    getNotes: function (limit = null, sort = "title", order = "asc") {
      let parent = this;
      api
        .get("/api/notes", {
          params: { limit: limit, sort: sort, order: order },
        })
        .then(function (response) {
          parent.notes = [];
          response.data.forEach(function (note) {
            parent.notes.push(new Note(note.title, note.lastModified));
          });
        })
        .catch(function (error) {
          parent.loadingFailed = true;
          if (!error.handled) {
            EventBus.$emit("unhandledServerError");
          }
        });
    },

    openNote: function (href, event) {
      EventBus.$emit("navigate", href, event);
    },
  },

  created: function () {
    this.getNotes(5, "lastModified", "desc");
  },
};
</script>