"use client";

import React from "react";

interface QuantitySelectorProps {
  value: number;
  onChange: (newValue: number) => void;
  min?: number;
  max?: number;
  size?: "sm" | "md";
}

export default function QuantitySelector({
  value,
  onChange,
  min = 0,
  max = 99,
  size = "md",
}: QuantitySelectorProps) {
  const handleDecrement = () => {
    if (value > min) {
      onChange(value - 1);
    }
  };

  const handleIncrement = () => {
    if (value < max) {
      onChange(value + 1);
    }
  };

  const handleKeyDown = (
    e: React.KeyboardEvent,
    action: "increment" | "decrement",
  ) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      if (action === "increment") {
        handleIncrement();
      } else {
        handleDecrement();
      }
    }
  };

  const sizeClasses = {
    sm: {
      container: "rounded-2xl shadow-sm",
      button: "w-6 h-6 text-sm",
      value: "w-8 text-sm",
    },
    md: {
      container: "rounded-2xl shadow-md",
      button: "w-8 h-8 text-base",
      value: "w-10 text-base",
    },
  };

  const classes = sizeClasses[size];

  return (
    <div
      className={`flex items-center bg-white border border-gray-200 ${classes.container} overflow-hidden`}
    >
      <button
        type="button"
        onClick={handleDecrement}
        onKeyDown={(e) => handleKeyDown(e, "decrement")}
        disabled={value <= min}
        className={`${classes.button} flex items-center justify-center text-red-500 hover:bg-red-50 transition disabled:opacity-30 disabled:cursor-not-allowed`}
        aria-label="Decrease quantity"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={2}
          stroke="currentColor"
          className="w-4 h-4"
        >
          <path strokeLinecap="round" strokeLinejoin="round" d="M5 12h14" />
        </svg>
      </button>

      <div
        className={`${classes.value} flex items-center justify-center font-semibold text-gray-800`}
      >
        {value}
      </div>

      <button
        type="button"
        onClick={handleIncrement}
        onKeyDown={(e) => handleKeyDown(e, "increment")}
        disabled={value >= max}
        className={`${classes.button} flex items-center justify-center text-red-500 hover:bg-red-50 transition disabled:opacity-30 disabled:cursor-not-allowed`}
        aria-label="Increase quantity"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          strokeWidth={2}
          stroke="currentColor"
          className="w-4 h-4"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            d="M12 5v14m7-7H5"
          />
        </svg>
      </button>
    </div>
  );
}
