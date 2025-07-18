<script setup>
import {
  monthName,
  yearName,
  getWeeksForMonth,
  isToday,
  dayIsInRange,
  isCurrentMonth,
  isLastDayOfMonth,
  isHoveringDayInRange,
  isHoveringNextDayInRange,
  CALENDAR_TYPES,
  CALENDAR_PERIODS,
} from '../helpers/DatePickerHelper';

import CalendarWeekLabel from './CalendarWeekLabel.vue';
import CalendarAction from './CalendarAction.vue';

const props = defineProps({
  calendarType: {
    type: String,
    default: 'start',
  },
  currentDate: Date,
  startCurrentDate: Date,
  endCurrentDate: Date,
  selectedStartDate: Date,
  selectingEndDate: Boolean,
  selectedEndDate: Date,
  hoveredEndDate: Date,
});

const emit = defineEmits([
  'updateHoveredEndDate',
  'selectDate',
  'prev',
  'next',
  'setView',
]);

const { START_CALENDAR } = CALENDAR_TYPES;
const { MONTH } = CALENDAR_PERIODS;

const emitHoveredEndDate = day => {
  emit('updateHoveredEndDate', day);
};

const emitSelectDate = day => {
  emit('selectDate', day);
};
const onClickPrev = () => {
  emit('prev');
};

const onClickNext = () => {
  emit('next');
};

const setViewMode = (type, mode) => {
  emit('setView', type, mode);
};

const weeks = calendarType => {
  return getWeeksForMonth(
    calendarType === START_CALENDAR
      ? props.startCurrentDate
      : props.endCurrentDate
  );
};

const isSelectedStartOrEndDate = day => {
  return (
    dayIsInRange(day, props.selectedStartDate, props.selectedStartDate) ||
    dayIsInRange(day, props.selectedEndDate, props.selectedEndDate)
  );
};

const isInRange = day => {
  return dayIsInRange(day, props.selectedStartDate, props.selectedEndDate);
};

const isInCurrentMonth = day => {
  return isCurrentMonth(
    day,
    props.calendarType === START_CALENDAR
      ? props.startCurrentDate
      : props.endCurrentDate
  );
};

const isHoveringInRange = day => {
  return isHoveringDayInRange(
    day,
    props.selectedStartDate,
    props.selectingEndDate,
    props.hoveredEndDate
  );
};

const isNextDayInRange = day => {
  return isHoveringNextDayInRange(
    day,
    props.selectedStartDate,
    props.selectedEndDate,
    props.hoveredEndDate
  );
};

const dayClasses = day => ({
  'text-n-slate-10 pointer-events-none': !isInCurrentMonth(day),
  'text-n-slate-12 hover:text-n-slate-12 hover:bg-n-blue-6 dark:hover:bg-n-blue-7':
    isInCurrentMonth(day),
  'bg-n-brand text-white':
    isSelectedStartOrEndDate(day) && isInCurrentMonth(day),
  'bg-n-blue-4 dark:bg-n-blue-5':
    (isInRange(day) || isHoveringInRange(day)) &&
    !isSelectedStartOrEndDate(day) &&
    isInCurrentMonth(day),
  'outline outline-1 outline-n-blue-8 -outline-offset-1 !text-n-mint-text':
    isToday(props.currentDate, day) && !isSelectedStartOrEndDate(day),
});
</script>

<template>
  <div class="flex flex-col w-full gap-2 max-h-[312px]">
    <CalendarAction
      :view-mode="MONTH"
      :calendar-type="calendarType"
      :first-button-label="
        monthName(
          calendarType === START_CALENDAR ? startCurrentDate : endCurrentDate
        )
      "
      :button-label="
        yearName(
          calendarType === START_CALENDAR ? startCurrentDate : endCurrentDate
        )
      "
      @prev="onClickPrev"
      @next="onClickNext"
      @set-view="setViewMode"
    />
    <CalendarWeekLabel />
    <div
      v-for="week in weeks(calendarType)"
      :key="week[0].getTime()"
      class="grid max-w-md grid-cols-7 gap-2 mx-auto overflow-hidden rounded-lg"
    >
      <div
        v-for="day in week"
        :key="day.getTime()"
        class="flex relative items-center justify-center w-9 h-8 py-1.5 px-2 font-medium text-sm rounded-lg cursor-pointer"
        :class="dayClasses(day)"
        @mouseenter="emitHoveredEndDate(day)"
        @mouseleave="emitHoveredEndDate(null)"
        @click="emitSelectDate(day)"
      >
        {{ day.getDate() }}
        <span
          v-if="
            (isInRange(day) || isHoveringInRange(day)) &&
            isNextDayInRange(day) &&
            !isLastDayOfMonth(day) &&
            isInCurrentMonth(day)
          "
          class="absolute bottom-0 w-6 h-8 ltr:-right-4 rtl:-left-4 bg-n-blue-4 dark:bg-n-blue-5 -z-10"
        />
      </div>
    </div>
  </div>
</template>
