<template>
  <div class="container">
    <div>
      <!-- Header -->
      <div class="mt-4 mb-4">
        <h1 class="h1 clickable-link text-center">
          <a href="/" @click.prevent="navigate('/', $event)">flatnotes</a>
        </h1>
      </div>

      <!-- Login -->
      <div
        v-if="currentView == views.login"
        class="d-flex justify-content-center"
      >
        <form v-on:submit.prevent="login">
          <div class="mb-3">
            <label for="username" class="form-label">Username</label>
            <input
              type="text"
              class="form-control"
              id="username"
              autocomplete="username"
              v-model="usernameInput"
              required
            />
          </div>
          <div class="mb-3">
            <label for="password" class="form-label">Password</label>
            <input
              type="password"
              class="form-control"
              id="password"
              autocomplete="current-password"
              v-model="passwordInput"
              required
            />
          </div>
          <div class="mb-3 form-check">
            <input
              type="checkbox"
              class="form-check-input"
              id="rememberMe"
              v-model="rememberMeInput"
            />
            <label class="form-check-label" for="rememberMe">Remember Me</label>
          </div>
          <button type="submit" class="btn btn-primary">Log In</button>
        </form>
      </div>

      <!-- Buttons -->
      <div v-if="currentView != 4" class="d-flex justify-content-center mb-4">
        <!-- Logout -->
        <button
          v-if="currentView == views.home"
          type="button"
          class="btn btn-sm btn-outline-dark mx-1"
          @click="logout"
        >
          Logout
        </button>

        <!-- New -->
        <button
          v-if="currentView == views.home"
          type="button"
          class="btn btn-sm btn-outline-primary mx-1"
          @click="newNote"
        >
          New
        </button>

        <!-- Close -->
        <a href="/" @click.prevent="navigate('/')">
          <button
            v-if="currentView == 2 && editMode == false"
            type="button"
            class="btn btn-sm btn-outline-secondary mx-1"
          >
            Close
          </button>
        </a>

        <!-- Edit -->
        <button
          v-if="
            currentView == views.note &&
            editMode == false &&
            noteLoadFailed == false
          "
          type="button"
          class="btn btn-sm btn-outline-warning mx-1"
          @click="toggleEditMode"
        >
          Edit
        </button>

        <!-- Delete -->
        <button
          v-if="
            currentView == views.note &&
            editMode == false &&
            noteLoadFailed == false
          "
          type="button"
          class="btn btn-sm btn-outline-danger mx-1"
          @click="deleteNote"
        >
          Delete
        </button>

        <!-- Cancel -->
        <button
          v-if="currentView == views.note && editMode == true"
          type="button"
          class="btn btn-sm btn-outline-secondary mx-1"
          @click="cancelNote"
        >
          Cancel
        </button>

        <!-- Save -->
        <button
          v-if="currentView == views.note && editMode == true"
          type="button"
          class="btn btn-sm btn-outline-success mx-1"
          @click="saveNote"
        >
          Save
        </button>
      </div>

      <!-- Search Input -->
      <form
        v-if="[views.search, views.home].includes(currentView)"
        v-on:submit.prevent="search"
      >
        <div class="form-group mb-4 d-flex justify-content-center">
          <input
            type="text"
            class="form-control"
            placeholder="Search"
            v-model="searchTerm"
            style="max-width: 500px"
          />
        </div>
      </form>

      <!-- Note -->
      <div v-if="currentView == views.note">
        <!-- Loading -->
        <div v-if="currentNote == null">
          <loading-indicator
            :failure-message="noteLoadFailedMessage"
            :failed="noteLoadFailed"
          />
        </div>

        <!-- Note Loaded -->
        <div v-else>
          <h2 v-if="editMode == false" class="mb-4">{{ currentNote.title }}</h2>
          <input
            v-else
            type="text"
            class="h2 title-input"
            v-model="titleInput"
            placeholder="Title"
          />

          <!-- Viewer -->
          <div class="mb-4 note">
            <div v-if="editMode == false" class="note-viewer">
              <viewer
                :initialValue="currentNote.content"
                height="600px"
                :options="viewerOptions"
              />
            </div>

            <!-- Editor -->
            <div v-else>
              <editor
                :initialValue="initialContent"
                initialEditType="markdown"
                previewStyle="tab"
                height="calc(100vh - 230px)"
                ref="toastUiEditor"
                :options="editorOptions"
                @change="startDraftSaveTimeout"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Search -->
      <div v-if="currentView == views.search">
        <!-- Searching -->
        <div v-if="searchResults == null">
          <loading-indicator
            loading-message="Searching..."
            failure-message="Search failed 😞"
            :failed="searchFailed"
          />
        </div>

        <!-- No Results -->
        <div v-else-if="searchResults.length == 0">
          <p class="text-center">No Results</p>
        </div>

        <!-- Search Results Loaded -->
        <div v-else>
          <div v-for="result in searchResults" :key="result.title" class="mb-5">
            <p class="h5 text-center clickable-link">
              <a
                v-html="result.titleHighlightsOrTitle"
                :href="result.href"
                @click.prevent="navigate(result.href, $event)"
              ></a>
            </p>
            <p
              class="text-center text-muted"
              v-html="result.contentHighlights"
            ></p>
          </div>
        </div>
      </div>

      <!-- Home -->
      <RecentlyModified v-if="currentView == views.home" />
    </div>
  </div>
</template>

<script>
export { default } from "./App.js";
</script>
