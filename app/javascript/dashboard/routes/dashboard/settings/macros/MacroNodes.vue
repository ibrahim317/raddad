<script>
import Draggable from 'vuedraggable';
import MacroNode from './MacroNode.vue';
import NextButton from 'dashboard/components-next/button/Button.vue';
import { getFileName } from './macroHelper';

export default {
  components: {
    Draggable,
    MacroNode,
    NextButton,
  },
  props: {
    errors: {
      type: Object,
      default: () => ({}),
    },
    modelValue: {
      type: Array,
      default: () => [],
    },
    files: {
      type: Array,
      default: () => [],
    },
  },
  emits: ['update:modelValue', 'resetAction', 'deleteNode', 'addNewNode'],
  computed: {
    actionData: {
      get() {
        return this.modelValue;
      },
      set(value) {
        this.$emit('update:modelValue', value);
      },
    },
  },
  methods: {
    fileName() {
      return getFileName(...arguments);
    },
  },
};
</script>

<template>
  <div class="macros__nodes">
    <div class="macro__node">
      <div>
        <span
          class="bg-n-solid-blue text-n-mint-text py-1 px-1.5 leading-none text-sm rounded-md"
        >
          {{ $t('MACROS.EDITOR.START_FLOW') }}
        </span>
      </div>
    </div>
    <Draggable
      :list="actionData"
      animation="200"
      item-key="id"
      ghost-class="ghost"
      tag="div"
      class="macros__nodes-draggable"
      handle=".macros__node-drag-handle"
    >
      <template #item="{ index: i }">
        <div :key="i" class="macro__node">
          <MacroNode
            v-model="actionData[i]"
            class="macros__node-action"
            type="add"
            :index="i"
            :error-key="errors[`action_${i}`]"
            :file-name="
              fileName(
                actionData[i].action_params[0],
                actionData[i].action_name,
                files
              )
            "
            :single-node="actionData.length === 1"
            @reset-action="$emit('resetAction', i)"
            @delete-node="$emit('deleteNode', i)"
          />
        </div>
      </template>
    </Draggable>
    <div class="macro__node">
      <div>
        <NextButton
          :title="$t('MACROS.EDITOR.ADD_BTN_TOOLTIP')"
          class="shadow-sm"
          solid
          teal
          icon="i-lucide-plus-circle"
          @click="$emit('addNewNode')"
        >
          {{ $t('MACROS.EDITOR.ADD_BTN_TOOLTIP') }}
        </NextButton>
      </div>
    </div>
    <div class="macro__node">
      <div>
        <span
          class="bg-n-solid-blue text-n-mint-text py-1 px-1.5 leading-none text-sm rounded-md"
        >
          {{ $t('MACROS.EDITOR.END_FLOW') }}
        </span>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.macros__nodes {
  max-width: 800px;
}

.macro__node:not(:last-child) {
  position: relative;
  padding-bottom: 2rem;
}

.macro__node:not(:last-child):not(.sortable-chosen):after,
.macros__nodes-draggable:after {
  @apply border-l dark:border-n-blue-11 border-n-blue-7 border-dashed ltr:ml-6 rtl:mr-6 absolute h-8 w-1 content-[""];
}

.macros__nodes-draggable {
  position: relative;
  padding-bottom: 2rem;
}

.macros__node-action-container {
  position: relative;
  .drag-handle {
    position: absolute;
    left: -1.5rem;
    top: 0.25rem;
    cursor: move;
  }
}
</style>
