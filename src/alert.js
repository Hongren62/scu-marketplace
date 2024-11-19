import React from "react";

export const Alert = ({ children }) => {
  return <div className="alert">{children}</div>;
};

export const AlertTitle = ({ children }) => {
  return <h4 className="alert-title">{children}</h4>;
};

export const AlertDescription = ({ children }) => {
  return <p className="alert-description">{children}</p>;
};
