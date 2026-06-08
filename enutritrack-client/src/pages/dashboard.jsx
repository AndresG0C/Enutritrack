import React, { useState, useEffect, useCallback, useMemo } from "react";
import {
  TrendingUp,
  TrendingDown,
  Minus,
  Activity,
  Weight,
  Calendar,
  Apple,
  UserCircle,
  Menu,
  LayoutDashboard,
  LogOut,
  ChevronDown,
  Moon,
  Sun,
  X,
  Bell,
  ArrowRight,
  ChevronRight,
  Zap,
  BookOpen,
  Clock,
  Users,
  Heart,
  Stethoscope,
  UserCheck,
  AlertCircle,
  ClipboardClock,
  HeartHandshake,
  AlertTriangle,
  Filter,
  BarChart3,
  PieChart,
  TrendingUp as TrendUp,
  Eye,
  Target,
  CheckCircle,
  Clock as ClockIcon,
} from "lucide-react";
import { useAuth } from "../context/auth/auth.context";
import Perfil from "../components/profile";
import UsuariosTracker from "../components/usuario/users-tracker";
import MedicalHistoryManager from "../components/medical-history-manager";
import MedicalAppointmentsManager from "../components/citas-medicas-manager";
import "../css/styles.css";
import NutritionManager from "../components/nutrition-manager";
import RecommendationsManager from "../components/recomendaciones-manager";
import { useTheme } from "../context/dark-mode.context";
import PhysicalActivityManager from "../components/actividad-fisica-manager";
import { useAppointments } from "../context/citas-medicas/citas-medicas.context";
import { useUsers } from "../context/user/user.context";
import { useNutrition } from "../context/nutrition/nutrition.context";
import { usePhysicalActivity } from "../context/activity/activity.context";

// Highcharts
import Highcharts from "highcharts";
import HighchartsReact from "highcharts-react-official";
import HighchartsMore from "highcharts/highcharts-more";
import AlertsManager from "../components/alertas-manager";
if (typeof HighchartsMore === "function") {
  HighchartsMore(Highcharts);
} else if (HighchartsMore && typeof HighchartsMore.default === "function") {
  HighchartsMore.default(Highcharts);
}

const formatNumber = (num) => {
  if (num === undefined || num === null || isNaN(num)) {
    return "0";
  }
  if (num >= 1000000) {
    return (num / 1000000).toFixed(1) + "M";
  }
  if (num >= 1000) {
    return (num / 1000).toFixed(1) + "K";
  }
  return num.toLocaleString();
};

const getTimeBasedGreeting = () => {
  const hour = new Date().getHours();
  if (hour < 12) return "Buenos días";
  if (hour < 18) return "Buenas tardes";
  return "Buenas noches";
};

const MetricCard = ({
  title,
  value,
  unit,
  icon: IconComponent,
  color,
  trend,
  subtitle,
  onClick,
  loading = false,
}) => {
  const { darkMode } = useTheme();

  const colorVariants = {
    emerald: {
      gradient: darkMode
        ? "from-emerald-500/10 via-emerald-500/5 to-transparent"
        : "from-emerald-500/20 via-emerald-500/10 to-transparent",
      border: darkMode ? "border-emerald-500/20" : "border-emerald-200",
      icon: darkMode
        ? "bg-gradient-to-br from-emerald-500/20 to-emerald-600/20 text-emerald-400 shadow-lg shadow-emerald-500/20"
        : "bg-gradient-to-br from-emerald-500 to-emerald-600 text-white shadow-lg shadow-emerald-500/30",
      glow: "shadow-emerald-500/10",
    },
    blue: {
      gradient: darkMode
        ? "from-blue-500/10 via-blue-500/5 to-transparent"
        : "from-blue-500/20 via-blue-500/10 to-transparent",
      border: darkMode ? "border-blue-500/20" : "border-blue-200",
      icon: darkMode
        ? "bg-gradient-to-br from-blue-500/20 to-blue-600/20 text-blue-400 shadow-lg shadow-blue-500/20"
        : "bg-gradient-to-br from-blue-500 to-blue-600 text-white shadow-lg shadow-blue-500/30",
      glow: "shadow-blue-500/10",
    },
    amber: {
      gradient: darkMode
        ? "from-amber-500/10 via-amber-500/5 to-transparent"
        : "from-amber-500/20 via-amber-500/10 to-transparent",
      border: darkMode ? "border-amber-500/20" : "border-amber-200",
      icon: darkMode
        ? "bg-gradient-to-br from-amber-500/20 to-amber-600/20 text-amber-400 shadow-lg shadow-amber-500/20"
        : "bg-gradient-to-br from-amber-500 to-amber-600 text-white shadow-lg shadow-amber-500/30",
      glow: "shadow-amber-500/10",
    },
    purple: {
      gradient: darkMode
        ? "from-purple-500/10 via-purple-500/5 to-transparent"
        : "from-purple-500/20 via-purple-500/10 to-transparent",
      border: darkMode ? "border-purple-500/20" : "border-purple-200",
      icon: darkMode
        ? "bg-gradient-to-br from-purple-500/20 to-purple-600/20 text-purple-400 shadow-lg shadow-purple-500/20"
        : "bg-gradient-to-br from-purple-500 to-purple-600 text-white shadow-lg shadow-purple-500/30",
      glow: "shadow-purple-500/10",
    },
  };

  const currentColor = colorVariants[color] || colorVariants.emerald;

  const getTrendColor = (trend) => {
    if (trend > 0) return darkMode ? "text-emerald-400" : "text-emerald-600";
    if (trend < 0) return darkMode ? "text-red-400" : "text-red-600";
    return darkMode ? "text-gray-400" : "text-gray-500";
  };

  const TrendIcon = trend > 0 ? TrendingUp : trend < 0 ? TrendingDown : Minus;

  return (
    <div
      onClick={onClick}
      className={`
        group relative overflow-hidden rounded-2xl border backdrop-blur-sm
        ${darkMode ? "bg-gray-800/60" : "bg-white/90"}
        ${currentColor.border}
        ${
          onClick ? "cursor-pointer hover:scale-[1.02] active:scale-[0.98]" : ""
        }
        transition-all duration-500 hover:shadow-2xl ${currentColor.glow}
        ${onClick ? "transform-gpu" : ""}
      `}
    >
      {/* Gradient overlay */}
      <div
        className={`absolute inset-0 bg-gradient-to-br ${currentColor.gradient} opacity-60`}
      />

      {/* Animated background effect on hover */}
      <div
        className={`absolute inset-0 bg-gradient-to-r ${currentColor.gradient} opacity-0 group-hover:opacity-100 transition-opacity duration-500`}
      />

      <div className="relative p-6">
        <div className="flex items-start justify-between mb-4">
          <div className="flex-1 min-w-0">
            <div className="flex items-center mb-3">
              <p
                className={`text-sm font-semibold tracking-wide ${
                  darkMode ? "text-gray-300" : "text-gray-600"
                } truncate uppercase`}
              >
                {title}
              </p>
              {loading && (
                <div className="ml-2 flex space-x-1">
                  <div
                    className={`w-1.5 h-1.5 rounded-full animate-bounce ${
                      darkMode ? "bg-gray-500" : "bg-gray-400"
                    }`}
                    style={{ animationDelay: "0ms" }}
                  />
                  <div
                    className={`w-1.5 h-1.5 rounded-full animate-bounce ${
                      darkMode ? "bg-gray-500" : "bg-gray-400"
                    }`}
                    style={{ animationDelay: "150ms" }}
                  />
                  <div
                    className={`w-1.5 h-1.5 rounded-full animate-bounce ${
                      darkMode ? "bg-gray-500" : "bg-gray-400"
                    }`}
                    style={{ animationDelay: "300ms" }}
                  />
                </div>
              )}
            </div>

            <div className="flex items-baseline mb-3">
              <p
                className={`text-4xl font-bold tracking-tight ${
                  darkMode ? "text-white" : "text-gray-900"
                } truncate`}
              >
                {loading ? "..." : formatNumber(value)}
              </p>
              {unit && (
                <span
                  className={`ml-2 text-lg font-semibold ${
                    darkMode ? "text-gray-400" : "text-gray-500"
                  }`}
                >
                  {unit}
                </span>
              )}
            </div>

            {subtitle && (
              <p
                className={`text-sm font-medium ${
                  darkMode ? "text-gray-400" : "text-gray-600"
                } mb-3`}
              >
                {subtitle}
              </p>
            )}

            {trend !== undefined && !loading && (
              <div
                className={`flex items-center px-2.5 py-1 rounded-lg ${getTrendColor(
                  trend
                )} ${darkMode ? "bg-gray-700/50" : "bg-gray-100"} w-fit`}
              >
                <TrendIcon className="w-4 h-4 mr-1.5" />
                <span className="text-sm font-bold">{Math.abs(trend)}%</span>
                <span
                  className={`ml-1.5 text-xs ${
                    darkMode ? "text-gray-400" : "text-gray-500"
                  }`}
                >
                  vs. anterior
                </span>
              </div>
            )}
          </div>

          <div
            className={`ml-4 flex-shrink-0 w-14 h-14 rounded-2xl flex items-center justify-center ${currentColor.icon} transform transition-transform duration-300 group-hover:scale-110 group-hover:rotate-6`}
          >
            <IconComponent className="w-7 h-7" />
          </div>
        </div>
      </div>
    </div>
  );
};

// Main Components
const DashboardHeader = ({ user }) => {
  const { darkMode } = useTheme();
  const [currentTime, setCurrentTime] = useState(new Date());

  useEffect(() => {
    const timer = setInterval(() => setCurrentTime(new Date()), 1000);
    return () => clearInterval(timer);
  }, []);

  const formatDate = (date) => {
    return date.toLocaleDateString("es-ES", {
      weekday: "long",
      year: "numeric",
      month: "long",
      day: "numeric",
    });
  };

  return (
    <div className="flex flex-col lg:flex-row lg:items-center lg:justify-between space-y-4 lg:space-y-0">
      <div>
        <h1
          className={`text-3xl lg:text-4xl font-bold ${
            darkMode ? "text-white" : "text-gray-900"
          } mb-2`}
        >
          {getTimeBasedGreeting()}, {user.nombre.split(" ")[0]}
        </h1>
        <div className="flex items-center space-x-6">
          <p
            className={`${
              darkMode ? "text-gray-400" : "text-gray-600"
            } flex items-center`}
          >
            <Calendar className="w-4 h-4 mr-2" />
            {formatDate(currentTime)}
          </p>
          <p
            className={`${
              darkMode ? "text-gray-400" : "text-gray-600"
            } flex items-center`}
            title="Especialidad médica"
          >
            <Stethoscope className="w-4 h-4 mr-2" />
            {user.especialida_id}
          </p>
        </div>
      </div>

      <div
        className={`${
          darkMode
            ? "bg-gray-800/80 border-gray-700/50"
            : "bg-white/80 border-gray-200/50"
        } backdrop-blur-sm rounded-2xl border px-6 py-4 shadow-lg`}
      >
        <div className="flex items-center space-x-4">
          <Clock
            className={`w-5 h-5 ${
              darkMode ? "text-gray-400" : "text-gray-500"
            }`}
          />
          <div>
            <p
              className={`text-sm ${
                darkMode ? "text-gray-400" : "text-gray-500"
              }`}
            >
              Hora actual
            </p>
            <p
              className={`text-xl font-bold ${
                darkMode ? "text-white" : "text-gray-900"
              }`}
            >
              {currentTime.toLocaleTimeString("es-ES", {
                hour: "2-digit",
                minute: "2-digit",
              })}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

const ChartsSection = ({ dashboardData, darkMode }) => {
  const baseChartOptions = {
    credits: { enabled: false },
    chart: {
      backgroundColor: "transparent",
      style: { fontFamily: "inherit" },
      height: 350,
    },
    title: {
      style: {
        color: darkMode ? "#fff" : "#1f2937",
        fontSize: "18px",
        fontWeight: "700",
        letterSpacing: "-0.025em",
      },
      align: "left",
    },
    subtitle: {
      style: {
        color: darkMode ? "#9ca3af" : "#6b7280",
        fontSize: "13px",
      },
      align: "left",
    },
    xAxis: {
      labels: {
        style: { color: darkMode ? "#d1d5db" : "#6b7280", fontSize: "12px" },
      },
      lineColor: darkMode ? "#374151" : "#e5e7eb",
      tickColor: darkMode ? "#374151" : "#e5e7eb",
      gridLineColor: darkMode ? "#374151" : "#f3f4f6",
    },
    yAxis: {
      labels: {
        style: { color: darkMode ? "#d1d5db" : "#6b7280", fontSize: "12px" },
      },
      gridLineColor: darkMode ? "#374151" : "#f3f4f6",
      title: {
        style: { color: darkMode ? "#d1d5db" : "#6b7280", fontWeight: "600" },
      },
    },
    legend: {
      itemStyle: { color: darkMode ? "#d1d5db" : "#374151", fontWeight: "500" },
      itemHoverStyle: { color: darkMode ? "#fff" : "#000" },
    },
    plotOptions: {
      series: {
        animation: { duration: 1000 },
        dataLabels: {
          style: { textOutline: "none", fontWeight: "600" },
        },
      },
    },
  };

  const appointmentsByStatusOptions = {
    ...baseChartOptions,
    chart: { ...baseChartOptions.chart, type: "pie" },
    title: { ...baseChartOptions.title, text: "Distribución de Citas" },
    subtitle: { ...baseChartOptions.subtitle, text: "Por estado actual" },
    series: [
      {
        name: "Citas",
        data: dashboardData.appointmentsByStatus || [],
        size: "80%",
        innerSize: "60%",
        dataLabels: {
          enabled: true,
          distance: -50,
          format: "<b>{point.percentage:.1f}%</b>",
          style: {
            fontSize: "14px",
            fontWeight: "bold",
            color: "white",
            textOutline: "2px contrast",
          },
        },
      },
    ],
    colors: darkMode
      ? ["#10b981", "#3b82f6", "#f59e0b", "#ef4444", "#8b5cf6"]
      : ["#059669", "#2563eb", "#d97706", "#dc2626", "#7c3aed"],
    plotOptions: {
      pie: {
        shadow: false,
        center: ["50%", "50%"],
        dataLabels: {
          connectorColor: darkMode ? "#4b5563" : "#d1d5db",
        },
      },
    },
    tooltip: {
      backgroundColor: darkMode ? "#1f2937" : "#ffffff",
      borderColor: darkMode ? "#374151" : "#e5e7eb",
      style: { color: darkMode ? "#f3f4f6" : "#1f2937" },
      pointFormat: "<b>{point.y}</b> citas ({point.percentage:.1f}%)",
    },
  };

  const patientsByGenderOptions = {
    ...baseChartOptions,
    chart: { ...baseChartOptions.chart, type: "column" },
    title: { ...baseChartOptions.title, text: "Pacientes por Género" },
    subtitle: { ...baseChartOptions.subtitle, text: "Distribución total" },
    xAxis: {
      ...baseChartOptions.xAxis,
      categories: dashboardData.patientsByGender?.categories || [],
    },
    yAxis: {
      ...baseChartOptions.yAxis,
      title: { ...baseChartOptions.yAxis.title, text: "Pacientes" },
    },
    series: [
      {
        name: "Pacientes",
        data: dashboardData.patientsByGender?.data || [],
        borderRadius: 8,
        color: {
          linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
          stops: darkMode
            ? [
                [0, "#10b981"],
                [1, "#059669"],
              ]
            : [
                [0, "#34d399"],
                [1, "#10b981"],
              ],
        },
        dataLabels: {
          enabled: true,
          style: {
            color: darkMode ? "#f3f4f6" : "#1f2937",
            fontSize: "13px",
            fontWeight: "700",
          },
        },
      },
    ],
    plotOptions: {
      column: {
        pointPadding: 0.1,
        borderWidth: 0,
        shadow: {
          color: darkMode
            ? "rgba(16, 185, 129, 0.3)"
            : "rgba(16, 185, 129, 0.2)",
          width: 10,
          offsetY: 3,
        },
      },
    },
    tooltip: {
      backgroundColor: darkMode ? "#1f2937" : "#ffffff",
      borderColor: darkMode ? "#374151" : "#e5e7eb",
      style: { color: darkMode ? "#f3f4f6" : "#1f2937" },
      pointFormat: "<b>{point.y}</b> pacientes",
    },
  };

  const weeklyActivityOptions = {
    ...baseChartOptions,
    chart: { ...baseChartOptions.chart, type: "areaspline" },
    title: { ...baseChartOptions.title, text: "Actividad Física Semanal" },
    subtitle: { ...baseChartOptions.subtitle, text: "Minutos de ejercicio" },
    xAxis: {
      ...baseChartOptions.xAxis,
      categories: dashboardData.weeklyActivity?.categories || [],
    },
    yAxis: {
      ...baseChartOptions.yAxis,
      title: { ...baseChartOptions.yAxis.title, text: "Minutos" },
    },
    series: [
      {
        name: "Actividad",
        data: dashboardData.weeklyActivity?.data || [],
        color: "#3b82f6",
        fillColor: {
          linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
          stops: darkMode
            ? [
                [0, "rgba(59, 130, 246, 0.3)"],
                [1, "rgba(59, 130, 246, 0)"],
              ]
            : [
                [0, "rgba(59, 130, 246, 0.2)"],
                [1, "rgba(59, 130, 246, 0)"],
              ],
        },
        lineWidth: 3,
        marker: {
          enabled: true,
          radius: 5,
          fillColor: "#3b82f6",
          lineWidth: 2,
          lineColor: darkMode ? "#1f2937" : "#ffffff",
        },
      },
    ],
    tooltip: {
      backgroundColor: darkMode ? "#1f2937" : "#ffffff",
      borderColor: darkMode ? "#374151" : "#e5e7eb",
      style: { color: darkMode ? "#f3f4f6" : "#1f2937" },
      valueSuffix: " min",
    },
  };

  const nutritionTrendsOptions = {
    ...baseChartOptions,
    chart: { ...baseChartOptions.chart, type: "spline" },
    title: { ...baseChartOptions.title, text: "Registros Nutricionales" },
    subtitle: { ...baseChartOptions.subtitle, text: "Tendencia mensual" },
    xAxis: {
      ...baseChartOptions.xAxis,
      categories: dashboardData.nutritionTrends?.categories || [],
    },
    yAxis: {
      ...baseChartOptions.yAxis,
      title: { ...baseChartOptions.yAxis.title, text: "Registros" },
    },
    series: [
      {
        name: "Registros",
        data: dashboardData.nutritionTrends?.data || [],
        color: "#8b5cf6",
        lineWidth: 3,
        marker: {
          enabled: true,
          radius: 6,
          symbol: "circle",
          fillColor: "#8b5cf6",
          lineWidth: 3,
          lineColor: darkMode ? "#1f2937" : "#ffffff",
        },
      },
    ],
    plotOptions: {
      spline: {
        marker: { enabled: true },
      },
    },
    tooltip: {
      backgroundColor: darkMode ? "#1f2937" : "#ffffff",
      borderColor: darkMode ? "#374151" : "#e5e7eb",
      style: { color: darkMode ? "#f3f4f6" : "#1f2937" },
      pointFormat: "<b>{point.y}</b> registros",
    },
  };

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
      {[
        { options: appointmentsByStatusOptions, key: "appointments" },
        { options: patientsByGenderOptions, key: "patients" },
        { options: weeklyActivityOptions, key: "activity" },
        { options: nutritionTrendsOptions, key: "nutrition" },
      ].map((chart, index) => (
        <div
          key={chart.key}
          className={`p-6 rounded-2xl transition-all duration-300 hover:shadow-xl ${
            darkMode
              ? "bg-gray-800/60 border border-gray-700/50 hover:border-gray-600/50"
              : "bg-white/90 border border-gray-200/50 hover:border-gray-300/50"
          } backdrop-blur-sm`}
          style={{ animationDelay: `${index * 100}ms` }}
        >
          <HighchartsReact highcharts={Highcharts} options={chart.options} />
        </div>
      ))}
    </div>
  );
};

const DashboardStats = ({ dashboardData, loading }) => {
  const stats = useMemo(
    () => [
      {
        title: "Pacientes Totales",
        value: dashboardData.totalPatients || 0,
        unit: "",
        icon: Users,
        color: "blue",
        trend: dashboardData.patientGrowth || 0,
        subtitle: dashboardData.newPatientsThisMonth
          ? `+${dashboardData.newPatientsThisMonth} este mes`
          : "",
      },
      {
        title: "Citas del Mes",
        value: dashboardData.monthlyAppointments || 0,
        unit: "",
        icon: Calendar,
        color: "emerald",
        trend: dashboardData.appointmentGrowth || 0,
        subtitle: dashboardData.completedAppointments
          ? `${dashboardData.completedAppointments} completadas`
          : "",
      },
      {
        title: "Actividad Física",
        value: dashboardData.totalActivityMinutes || 0,
        unit: "min",
        icon: Activity,
        color: "purple",
        trend: dashboardData.activityGrowth || 0,
        subtitle: dashboardData.avgActivityPerPatient
          ? `Promedio: ${dashboardData.avgActivityPerPatient}min/paciente`
          : "",
      },
      {
        title: "Registros Nutricionales",
        value: dashboardData.totalNutritionRecords || 0,
        unit: "",
        icon: Apple,
        color: "amber",
        trend: dashboardData.nutritionGrowth || 0,
        subtitle: dashboardData.avgCalories
          ? `Promedio: ${dashboardData.avgCalories} cal/día`
          : "",
      },
    ],
    [dashboardData]
  );

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
      {stats.map((stat, index) => (
        <MetricCard key={index} {...stat} loading={loading} />
      ))}
    </div>
  );
};

// Nueva sección: Próximas Citas
const UpcomingAppointments = ({ appointments, darkMode }) => {
  const formatDate = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleDateString("es-ES", {
      day: "numeric",
      month: "short",
      year: "numeric",
    });
  };

  const formatTime = (dateString) => {
    const date = new Date(dateString);
    return date.toLocaleTimeString("es-ES", {
      hour: "2-digit",
      minute: "2-digit",
    });
  };

  const getStatusColor = (status) => {
    switch (status?.toLowerCase()) {
      case "confirmada":
        return "text-emerald-500";
      case "pendiente":
        return "text-amber-500";
      case "cancelada":
        return "text-red-500";
      default:
        return "text-gray-500";
    }
  };

  const upcomingAppointments =
    appointments
      ?.filter((apt) => {
        const aptDate = new Date(apt.fechaHoraProgramada);
        const now = new Date();
        return aptDate >= now;
      })
      ?.slice(0, 5) || [];

  return (
    <div
      className={`p-6 rounded-2xl transition-all duration-300 ${
        darkMode
          ? "bg-gray-800/60 border border-gray-700/50"
          : "bg-white/90 border border-gray-200/50"
      } backdrop-blur-sm hover:shadow-xl`}
    >
      <div className="flex items-center mb-6">
        <div
          className={`p-3 rounded-xl ${
            darkMode ? "bg-blue-500/20" : "bg-blue-100"
          } mr-4`}
        >
          <Calendar
            className={`w-6 h-6 ${
              darkMode ? "text-blue-400" : "text-blue-600"
            }`}
          />
        </div>
        <div>
          <h3
            className={`text-xl font-bold ${
              darkMode ? "text-white" : "text-gray-900"
            }`}
          >
            Próximas Citas
          </h3>
          <p
            className={`text-sm ${
              darkMode ? "text-gray-400" : "text-gray-600"
            }`}
          >
            Agenda de hoy y próximos días
          </p>
        </div>
      </div>

      <div className="space-y-4">
        {upcomingAppointments.length > 0 ? (
          upcomingAppointments.map((appointment, index) => (
            <div
              key={appointment.id || index}
              className={`p-4 rounded-xl border transition-all duration-200 hover:shadow-md ${
                darkMode
                  ? "bg-gray-700/40 border-gray-600/50 hover:border-gray-500/50"
                  : "bg-gray-50 border-gray-200 hover:border-gray-300"
              }`}
            >
              <div className="flex items-center justify-between mb-2">
                <h4
                  className={`font-semibold ${
                    darkMode ? "text-white" : "text-gray-900"
                  }`}
                >
                  {appointment.paciente?.nombre || "Paciente"}
                </h4>
                <span
                  className={`text-sm font-medium ${getStatusColor(
                    appointment.estadoCita?.nombre
                  )}`}
                >
                  {appointment.estadoCita?.nombre || "Pendiente"}
                </span>
              </div>
              <div className="flex items-center justify-between text-sm">
                <div className="flex items-center space-x-4">
                  <div className="flex items-center">
                    <Calendar className="w-4 h-4 mr-1 text-gray-400" />
                    <span
                      className={darkMode ? "text-gray-300" : "text-gray-600"}
                    >
                      {formatDate(appointment.fechaHoraProgramada)}
                    </span>
                  </div>
                  <div className="flex items-center">
                    <ClockIcon className="w-4 h-4 mr-1 text-gray-400" />
                    <span
                      className={darkMode ? "text-gray-300" : "text-gray-600"}
                    >
                      {formatTime(appointment.fechaHoraProgramada)}
                    </span>
                  </div>
                </div>
                {appointment.tipoCita && (
                  <span
                    className={`px-2 py-1 rounded-full text-xs font-medium ${
                      darkMode
                        ? "bg-gray-600 text-gray-300"
                        : "bg-gray-200 text-gray-700"
                    }`}
                  >
                    {appointment.tipoCita.nombre}
                  </span>
                )}
              </div>
            </div>
          ))
        ) : (
          <div
            className={`text-center py-8 ${
              darkMode ? "text-gray-400" : "text-gray-500"
            }`}
          >
            <Calendar className="w-12 h-12 mx-auto mb-3 opacity-50" />
            <p>No hay citas programadas</p>
          </div>
        )}
      </div>
    </div>
  );
};

// Nueva sección: Indicadores de Salud
const HealthIndicators = ({ dashboardData, darkMode }) => {
  const indicators = [
    {
      title: "Pacientes Activos",
      value: dashboardData.totalPatients || 0,
      target: 100,
      icon: UserCheck,
      color: "emerald",
      description: "Pacientes en seguimiento activo",
    },
    {
      title: "Cumplimiento Metas",
      value: "78%",
      target: "85%",
      icon: Target,
      color: "blue",
      description: "Pacientes que alcanzan sus objetivos",
    },
    {
      title: "Satisfacción",
      value: "4.8",
      target: "5.0",
      icon: Heart,
      color: "purple",
      description: "Calificación promedio de pacientes",
    },
    {
      title: "Tiempo Respuesta",
      value: "2.3h",
      target: "4h",
      icon: ClockIcon,
      color: "amber",
      description: "Tiempo promedio de respuesta",
    },
  ];

  const getProgressColor = (value, target) => {
    const percentage =
      typeof value === "string"
        ? parseFloat(value) / parseFloat(target)
        : value / target;

    if (percentage >= 0.9) return "emerald";
    if (percentage >= 0.7) return "blue";
    if (percentage >= 0.5) return "amber";
    return "red";
  };

  return (
    <div
      className={`p-6 rounded-2xl transition-all duration-300 ${
        darkMode
          ? "bg-gray-800/60 border border-gray-700/50"
          : "bg-white/90 border border-gray-200/50"
      } backdrop-blur-sm hover:shadow-xl`}
    >
      <div className="flex items-center mb-6">
        <div
          className={`p-3 rounded-xl ${
            darkMode ? "bg-purple-500/20" : "bg-purple-100"
          } mr-4`}
        >
          <Activity
            className={`w-6 h-6 ${
              darkMode ? "text-purple-400" : "text-purple-600"
            }`}
          />
        </div>
        <div>
          <h3
            className={`text-xl font-bold ${
              darkMode ? "text-white" : "text-gray-900"
            }`}
          >
            Indicadores de Salud
          </h3>
          <p
            className={`text-sm ${
              darkMode ? "text-gray-400" : "text-gray-600"
            }`}
          >
            Métricas clave del consultorio
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {indicators.map((indicator, index) => {
          const IconComponent = indicator.icon;
          const progressColor = getProgressColor(
            indicator.value,
            indicator.target
          );

          return (
            <div
              key={index}
              className={`p-4 rounded-xl border transition-all duration-200 hover:shadow-md ${
                darkMode
                  ? "bg-gray-700/40 border-gray-600/50 hover:border-gray-500/50"
                  : "bg-gray-50 border-gray-200 hover:border-gray-300"
              }`}
            >
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center">
                  <div
                    className={`p-2 rounded-lg ${
                      darkMode
                        ? `bg-${indicator.color}-500/20`
                        : `bg-${indicator.color}-100`
                    } mr-3`}
                  >
                    <IconComponent
                      className={`w-5 h-5 ${
                        darkMode
                          ? `text-${indicator.color}-400`
                          : `text-${indicator.color}-600`
                      }`}
                    />
                  </div>
                  <div>
                    <h4
                      className={`font-semibold ${
                        darkMode ? "text-white" : "text-gray-900"
                      }`}
                    >
                      {indicator.title}
                    </h4>
                    <p
                      className={`text-xs ${
                        darkMode ? "text-gray-400" : "text-gray-500"
                      }`}
                    >
                      {indicator.description}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <div
                    className={`text-2xl font-bold ${
                      darkMode ? "text-white" : "text-gray-900"
                    }`}
                  >
                    {indicator.value}
                  </div>
                  <div
                    className={`text-xs ${
                      darkMode ? "text-gray-400" : "text-gray-500"
                    }`}
                  >
                    Meta: {indicator.target}
                  </div>
                </div>
              </div>

              <div
                className={`w-full bg-gray-200 rounded-full h-2 ${
                  darkMode ? "bg-gray-600" : "bg-gray-200"
                }`}
              >
                <div
                  className={`h-2 rounded-full bg-${progressColor}-500 transition-all duration-500`}
                  style={{
                    width:
                      typeof indicator.value === "string"
                        ? `${
                            (parseFloat(indicator.value) /
                              parseFloat(indicator.target)) *
                            100
                          }%`
                        : `${(indicator.value / indicator.target) * 100}%`,
                  }}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Nueva sección: Alertas y Recordatorios
const AlertsSection = ({ dashboardData, darkMode }) => {
  const alerts = [
    {
      type: "warning",
      title: "Revisión de Historiales Pendiente",
      description: "5 pacientes requieren actualización de historial médico",
      icon: ClipboardClock,
      time: "2 días",
      priority: "alta",
    },
    {
      type: "info",
      title: "Recordatorio de Citas",
      description: "3 citas programadas para mañana",
      icon: Calendar,
      time: "1 día",
      priority: "media",
    },
    {
      type: "success",
      title: "Metas Alcanzadas",
      description: "8 pacientes completaron sus objetivos este mes",
      icon: CheckCircle,
      time: "1 semana",
      priority: "baja",
    },
  ];

  const getAlertColor = (type) => {
    switch (type) {
      case "warning":
        return darkMode ? "text-amber-400" : "text-amber-600";
      case "info":
        return darkMode ? "text-blue-400" : "text-blue-600";
      case "success":
        return darkMode ? "text-emerald-400" : "text-emerald-600";
      default:
        return darkMode ? "text-gray-400" : "text-gray-600";
    }
  };

  const getAlertBgColor = (type) => {
    switch (type) {
      case "warning":
        return darkMode ? "bg-amber-500/10" : "bg-amber-50";
      case "info":
        return darkMode ? "bg-blue-500/10" : "bg-blue-50";
      case "success":
        return darkMode ? "bg-emerald-500/10" : "bg-emerald-50";
      default:
        return darkMode ? "bg-gray-500/10" : "bg-gray-50";
    }
  };

  return (
    <div
      className={`p-6 rounded-2xl transition-all duration-300 ${
        darkMode
          ? "bg-gray-800/60 border border-gray-700/50"
          : "bg-white/90 border border-gray-200/50"
      } backdrop-blur-sm hover:shadow-xl`}
    >
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center">
          <div
            className={`p-3 rounded-xl ${
              darkMode ? "bg-red-500/20" : "bg-red-100"
            } mr-4`}
          >
            <AlertTriangle
              className={`w-6 h-6 ${
                darkMode ? "text-red-400" : "text-red-600"
              }`}
            />
          </div>
          <div>
            <h3
              className={`text-xl font-bold ${
                darkMode ? "text-white" : "text-gray-900"
              }`}
            >
              Alertas y Recordatorios
            </h3>
            <p
              className={`text-sm ${
                darkMode ? "text-gray-400" : "text-gray-600"
              }`}
            >
              Actividades pendientes y notificaciones
            </p>
          </div>
        </div>
        <div
          className={`px-3 py-1 rounded-full text-sm font-medium ${
            darkMode ? "bg-gray-700 text-gray-300" : "bg-gray-200 text-gray-700"
          }`}
        >
          {alerts.length} alertas
        </div>
      </div>

      <div className="space-y-4">
        {alerts.map((alert, index) => {
          const IconComponent = alert.icon;
          return (
            <div
              key={index}
              className={`p-4 rounded-xl border transition-all duration-200 hover:shadow-md ${getAlertBgColor(
                alert.type
              )} ${
                darkMode
                  ? "border-gray-600/50 hover:border-gray-500/50"
                  : "border-gray-200 hover:border-gray-300"
              }`}
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex items-center">
                  <IconComponent
                    className={`w-5 h-5 mr-3 ${getAlertColor(alert.type)}`}
                  />
                  <h4
                    className={`font-semibold ${
                      darkMode ? "text-white" : "text-gray-900"
                    }`}
                  >
                    {alert.title}
                  </h4>
                </div>
                <span
                  className={`text-xs px-2 py-1 rounded-full ${
                    alert.priority === "alta"
                      ? darkMode
                        ? "bg-red-500/20 text-red-400"
                        : "bg-red-100 text-red-700"
                      : alert.priority === "media"
                      ? darkMode
                        ? "bg-amber-500/20 text-amber-400"
                        : "bg-amber-100 text-amber-700"
                      : darkMode
                      ? "bg-emerald-500/20 text-emerald-400"
                      : "bg-emerald-100 text-emerald-700"
                  }`}
                >
                  {alert.priority}
                </span>
              </div>
              <p
                className={`text-sm mb-2 ${
                  darkMode ? "text-gray-300" : "text-gray-600"
                }`}
              >
                {alert.description}
              </p>
              <div className="flex items-center justify-between text-xs">
                <span className={darkMode ? "text-gray-400" : "text-gray-500"}>
                  Hace {alert.time}
                </span>
                <button
                  className={`font-medium ${getAlertColor(
                    alert.type
                  )} hover:underline`}
                >
                  Ver detalles
                </button>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

// Main Dashboard Content
const DashboardContent = () => {
  const { user } = useAuth();
  const { darkMode } = useTheme();
  const { appointments, getMyAppointments } = useAppointments();
  const { getUsersByDoctorId } = useUsers();
  const { getFoodRecordsByUser } = useNutrition();
  const { getPhysicalActivitiesByUser } = usePhysicalActivity();

  const [dashboardData, setDashboardData] = useState({});
  const [loading, setLoading] = useState(true);

  const calculateDashboardData = useCallback(async () => {
    setLoading(true);
    try {
      // Obtener datos de pacientes
      const patients = await getUsersByDoctorId(user.id);
      const totalPatients = patients?.length || 0;

      // Obtener citas
      const appointmentsData = await getMyAppointments();
      const allAppointments = appointmentsData?.citas || [];

      const monthlyAppointments = allAppointments.filter((apt) => {
        const aptDate = new Date(apt.fechaHoraProgramada);
        const monthStart = new Date();
        monthStart.setDate(1);
        monthStart.setHours(0, 0, 0, 0);
        return aptDate >= monthStart;
      }).length;

      // Calcular datos de pacientes por género
      const genderCount = patients?.reduce((acc, patient) => {
        const gender = patient.genero?.nombre || "No especificado";
        acc[gender] = (acc[gender] || 0) + 1;
        return acc;
      }, {});

      const patientsByGender = {
        categories: Object.keys(genderCount || {}),
        data: Object.values(genderCount || {}),
      };

      // Calcular citas por estado
      const statusCount = allAppointments.reduce((acc, apt) => {
        const status = apt.estadoCita?.nombre || "Sin estado";
        acc[status] = (acc[status] || 0) + 1;
        return acc;
      }, {});

      const appointmentsByStatus = Object.entries(statusCount || {}).map(
        ([name, y]) => ({ name, y })
      );

      // Datos de actividad física (simulados por ahora)
      const weeklyActivity = {
        categories: ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"],
        data: [45, 52, 38, 60, 48, 35, 55],
      };

      // Tendencias nutricionales (simuladas por ahora)
      const nutritionTrends = {
        categories: ["Sem 1", "Sem 2", "Sem 3", "Sem 4"],
        data: [28, 32, 45, 38],
      };

      setDashboardData({
        totalPatients,
        monthlyAppointments,
        patientsByGender,
        appointmentsByStatus,
        weeklyActivity,
        nutritionTrends,
        totalActivityMinutes: weeklyActivity.data.reduce((a, b) => a + b, 0),
        totalNutritionRecords: nutritionTrends.data.reduce((a, b) => a + b, 0),
        patientGrowth: 8.2,
        appointmentGrowth: 12.5,
        activityGrowth: 5.8,
        nutritionGrowth: 15.2,
        newPatientsThisMonth: Math.floor(totalPatients * 0.1),
        completedAppointments: Math.floor(monthlyAppointments * 0.7),
        avgActivityPerPatient: Math.round(
          weeklyActivity.data.reduce((a, b) => a + b, 0) / 7
        ),
        avgCalories: 1850,
        appointments: allAppointments,
      });
    } catch (error) {
      console.error("Error calculando datos del dashboard:", error);
    } finally {
      setLoading(false);
    }
  }, [user.id, getUsersByDoctorId, getMyAppointments]);

  useEffect(() => {
    calculateDashboardData();
  }, []);

  return (
    <div className="p-6 space-y-8">
      <DashboardHeader user={user} />

      <DashboardStats dashboardData={dashboardData} loading={loading} />

      {/* Nueva sección con grid de 2 columnas para contenido adicional */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
        <UpcomingAppointments
          appointments={dashboardData.appointments}
          darkMode={darkMode}
        />
        <HealthIndicators dashboardData={dashboardData} darkMode={darkMode} />
      </div>

      <ChartsSection dashboardData={dashboardData} darkMode={darkMode} />

      {/* Sección de Alertas */}
      <AlertsSection dashboardData={dashboardData} darkMode={darkMode} />
    </div>
  );
};

// Sidebar Navigation (sin cambios)
const Sidebar = ({
  isOpen,
  onClose,
  activeContent,
  setActiveContent,
  user,
  onLogout,
}) => {
  const { darkMode } = useTheme();
  const [expandedSections, setExpandedSections] = useState({
    Principal: true,
    "Gestión de pacientes": true,
    "Monitoreo y seguimiento": true,
  });

  const toggleSection = (sectionTitle) => {
    setExpandedSections((prev) => ({
      ...prev,
      [sectionTitle]: !prev[sectionTitle],
    }));
  };

  const navigationItems = [
    {
      section: "Principal",
      items: [
        { id: "dashboard", name: "Dashboard", icon: LayoutDashboard },
        { id: "perfil", name: "Perfil", icon: UserCircle },
      ],
    },
    {
      section: "Gestión de pacientes",
      items: [
        { id: "usuarios", name: "Pacientes", icon: Users },
        {
          id: "historialmedico",
          name: "Historiales médicos",
          icon: ClipboardClock,
        },
        { id: "citas", name: "Citas médicas", icon: Calendar },
      ],
    },
    {
      section: "Monitoreo y seguimiento",
      items: [
        { id: "alertas", name: "Alertas", icon: AlertTriangle },
        { id: "nutricion", name: "Registros nutricionales", icon: Apple },
        { id: "actividadfiscia", name: "Actividades físicas", icon: Activity },
        {
          id: "recomendaciones",
          name: "Recomendaciones",
          icon: HeartHandshake,
        },
      ],
    },
  ];

  const handleNavigation = useCallback(
    (itemId) => {
      setActiveContent(itemId);
      if (window.innerWidth < 1024) {
        onClose();
      }
    },
    [setActiveContent, onClose]
  );

  return (
    <>
      {isOpen && (
        <div
          className="fixed inset-0 bg-black/50 backdrop-blur-sm z-40 lg:hidden"
          onClick={onClose}
        />
      )}

      <aside
        className={`
          fixed inset-y-0 left-0 z-50 w-72 transform transition-all duration-300 ease-out
          ${isOpen ? "translate-x-0" : "-translate-x-full"}
          lg:translate-x-0
          ${
            darkMode
              ? "bg-gray-900/95 border-gray-700/50"
              : "bg-white/95 border-gray-200/50"
          }
          backdrop-blur-xl border-r shadow-2xl
        `}
      >
        <div
          className={`
          flex items-center justify-between h-20 px-6 border-b
          ${
            darkMode
              ? "border-gray-700/50 bg-gradient-to-r from-emerald-900/30 to-emerald-800/20"
              : "border-gray-200/50 bg-gradient-to-r from-emerald-50 to-emerald-100/50"
          }
        `}
        >
          <div className="flex items-center">
            <img
              src="/Logo_ico.png"
              alt="Enutritrack Logo"
              className="w-16 h-16 object-contain"
              onError={(e) => {
                e.target.style.display = "none";
              }}
            />
            <div className="ml-3">
              <h1
                className={`text-xl font-bold ${
                  darkMode ? "text-white" : "text-gray-800"
                }`}
              >
                EnutriTrack
              </h1>
              <p
                className={`text-xs ${
                  darkMode ? "text-gray-400" : "text-gray-500"
                }`}
              >
                Panel Médico
              </p>
            </div>
          </div>
          <button
            onClick={onClose}
            className={`lg:hidden p-2 rounded-lg transition-colors ${
              darkMode
                ? "text-gray-400 hover:text-gray-300 hover:bg-gray-700"
                : "text-gray-400 hover:text-gray-500 hover:bg-gray-100"
            }`}
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <nav className="flex-1 px-4 py-4 space-y-0 overflow-y-auto">
          {navigationItems.map((section, sectionIndex) => {
            const isExpanded = expandedSections[section.section];
            return (
              <div key={sectionIndex}>
                <button
                  onClick={() => toggleSection(section.section)}
                  className={`
                    w-full flex items-center justify-between px-4 py-3 text-xs font-semibold uppercase tracking-wider rounded-xl transition-all duration-200
                    ${
                      darkMode
                        ? "text-gray-500 hover:text-gray-300 hover:bg-gray-800/50"
                        : "text-gray-400 hover:text-gray-500 hover:bg-gray-100"
                    }
                  `}
                >
                  <span>{section.section}</span>
                  <ChevronDown
                    className={`w-4 h-4 transition-transform ${
                      isExpanded ? "rotate-180" : ""
                    }`}
                  />
                </button>

                {isExpanded && (
                  <div className="space-y-2 mt-2">
                    {section.items.map((item) => {
                      const isActive = activeContent === item.id;
                      const IconComponent = item.icon;

                      return (
                        <button
                          key={item.id}
                          onClick={() => handleNavigation(item.id)}
                          className={`
                            w-full group flex items-center px-4 py-3 text-sm font-medium rounded-xl
                            transition-all duration-200 relative overflow-hidden
                            ${
                              isActive
                                ? darkMode
                                  ? "bg-emerald-500/20 text-emerald-400 shadow-lg border border-emerald-500/30"
                                  : "bg-emerald-100 text-emerald-700 shadow-md border border-emerald-200"
                                : darkMode
                                ? "text-gray-300 hover:bg-gray-800/50 hover:text-white"
                                : "text-gray-600 hover:bg-gray-100 hover:text-gray-900"
                            }
                          `}
                        >
                          {isActive && (
                            <div
                              className={`absolute left-0 top-0 bottom-0 w-1 ${
                                darkMode ? "bg-emerald-400" : "bg-emerald-500"
                              } rounded-r-full`}
                            />
                          )}
                          <IconComponent
                            className={`w-5 h-5 mr-3 transition-transform group-hover:scale-110 ${
                              isActive ? "scale-110" : ""
                            }`}
                          />
                          <span className="truncate">{item.name}</span>
                          {isActive && (
                            <ChevronRight className="w-4 h-4 ml-auto" />
                          )}
                        </button>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </nav>

        <div
          className={`p-4 border-t ${
            darkMode
              ? "border-gray-700/50 bg-gray-800/30"
              : "border-gray-200/50 bg-gray-50/30"
          }`}
        >
          <div
            className={`flex items-center p-4 ${
              darkMode ? "bg-gray-800" : "bg-white"
            } rounded-xl shadow-sm mb-4 border ${
              darkMode ? "border-gray-700/50" : "border-gray-200/50"
            }`}
          >
            <div className="w-12 h-12 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-full flex items-center justify-center mr-3 shadow-md">
              <span className="text-white font-semibold">
                {user.nombre.charAt(0)}
              </span>
            </div>
            <div className="flex-1 min-w-0">
              <p
                className={`text-sm font-semibold ${
                  darkMode ? "text-white" : "text-gray-900"
                } truncate`}
              >
               {user.nombre}
              </p>
              <p
                className={`text-xs ${
                  darkMode ? "text-gray-400" : "text-gray-500"
                } truncate`}
              >
                {user.email}
              </p>
            </div>
          </div>

          <button
            onClick={onLogout}
            className={`
              w-full flex items-center px-4 py-3 text-sm font-medium rounded-xl
              transition-all duration-200 group
              ${
                darkMode
                  ? "text-red-400 hover:bg-red-900/20"
                  : "text-red-600 hover:bg-red-50"
              }
            `}
          >
            <LogOut className="w-5 h-5 mr-3 group-hover:scale-110 transition-transform" />
            <span>Cerrar Sesión</span>
          </button>
        </div>
      </aside>
    </>
  );
};

// Header Component (sin cambios)
const Header = ({ onToggleSidebar, user, onLogout }) => {
  const { darkMode, toggleDarkMode } = useTheme();
  const [userMenuOpen, setUserMenuOpen] = useState(false);

  return (
    <header
      className={`
      ${
        darkMode
          ? "bg-gray-900/80 border-gray-700/50"
          : "bg-white/80 border-gray-200/50"
      }
      backdrop-blur-xl border-b sticky top-0 z-30 transition-all duration-300
    `}
    >
      <div className="px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          <div className="flex items-center">
            <button
              onClick={onToggleSidebar}
              className={`lg:hidden p-2 rounded-lg transition-colors ${
                darkMode
                  ? "text-gray-400 hover:text-gray-300 hover:bg-gray-700"
                  : "text-gray-400 hover:text-gray-500 hover:bg-gray-100"
              }`}
            >
              <Menu className="h-6 w-6" />
            </button>
          </div>

          <div className="flex items-center space-x-3">
            <button
              onClick={toggleDarkMode}
              className={`
                p-2.5 rounded-xl transition-all duration-300 shadow-lg
                ${
                  darkMode
                    ? "bg-amber-500 hover:bg-amber-400 text-white hover:shadow-amber-500/25"
                    : "bg-gray-800 hover:bg-gray-700 text-white hover:shadow-gray-800/25"
                }
                hover:shadow-xl hover:scale-105
              `}
            >
              {darkMode ? (
                <Sun className="w-5 h-5" />
              ) : (
                <Moon className="w-5 h-5" />
              )}
            </button>

            <div className="relative">
              <button
                onClick={() => setUserMenuOpen(!userMenuOpen)}
                className={`flex items-center space-x-3 p-2 rounded-xl transition-colors ${
                  darkMode ? "hover:bg-gray-700" : "hover:bg-gray-100"
                }`}
              >
                <div className="w-9 h-9 bg-gradient-to-br from-emerald-500 to-emerald-600 rounded-full flex items-center justify-center shadow-md">
                  <span className="text-white text-sm font-semibold">
                    {user.nombre.charAt(0)}
                  </span>
                </div>
                <div className="hidden sm:block text-left">
                  <p
                    className={`text-sm font-medium ${
                      darkMode ? "text-white" : "text-gray-900"
                    }`}
                  >
                   {user.nombre.split(" ")[0]}
                  </p>
                  <p
                    className={`text-xs ${
                      darkMode ? "text-gray-400" : "text-gray-500"
                    }`}
                  >
                    Médico
                  </p>
                </div>
                <ChevronDown
                  className={`h-4 w-4 transition-transform ${
                    userMenuOpen ? "rotate-180" : ""
                  } ${darkMode ? "text-gray-400" : "text-gray-500"}`}
                />
              </button>

              {userMenuOpen && (
                <div
                  className={`
                  absolute right-0 mt-2 w-64 rounded-xl shadow-lg border py-2 z-50
                  ${
                    darkMode
                      ? "bg-gray-800 border-gray-700"
                      : "bg-white border-gray-200"
                  }
                  backdrop-blur-xl
                `}
                >
                  <div
                    className={`px-4 py-3 border-b ${
                      darkMode ? "border-gray-700" : "border-gray-100"
                    }`}
                  >
                    <p
                      className={`text-sm font-medium ${
                        darkMode ? "text-white" : "text-gray-900"
                      }`}
                    >
                     {user?.nombre}
                    </p>
                    <p
                      className={`text-xs ${
                        darkMode ? "text-gray-400" : "text-gray-500"
                      }`}
                    >
                      {user?.correo || user?.email}
                    </p>
                  </div>
                  <button
                    onClick={() => {
                      onLogout();
                      setUserMenuOpen(false);
                    }}
                    className={`flex items-center w-full px-4 py-2 text-sm transition-colors ${
                      darkMode
                        ? "text-red-400 hover:bg-red-900/20"
                        : "text-red-600 hover:bg-red-50"
                    }`}
                  >
                    <LogOut className="h-4 w-4 mr-3" />
                    Cerrar Sesión
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

// Generic Content for other sections (sin cambios)
const GenericContent = ({ title }) => {
  const { darkMode } = useTheme();

  return (
    <div className="p-6">
      <div className="max-w-7xl mx-auto">
        <div
          className={`${
            darkMode
              ? "bg-gray-800/80 border-gray-700/50"
              : "bg-white/80 border-gray-200/50"
          } backdrop-blur-sm rounded-2xl border p-8`}
        >
          <h1
            className={`text-3xl font-bold ${
              darkMode ? "text-white" : "text-gray-900"
            } mb-6`}
          >
            {title}
          </h1>
          <p
            className={`text-lg ${
              darkMode ? "text-gray-300" : "text-gray-600"
            } mb-8`}
          >
            Esta sección está en desarrollo. Próximamente tendrás acceso a todas
            las funcionalidades de {title}.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[1, 2, 3].map((item) => (
              <div
                key={item}
                className={`p-6 rounded-xl border ${
                  darkMode
                    ? "bg-gray-700/50 border-gray-600"
                    : "bg-gray-50 border-gray-200"
                }`}
              >
                <h3
                  className={`font-semibold mb-2 ${
                    darkMode ? "text-white" : "text-gray-900"
                  }`}
                >
                  Función {item}
                </h3>
                <p
                  className={`text-sm ${
                    darkMode ? "text-gray-400" : "text-gray-600"
                  }`}
                >
                  Descripción de la funcionalidad {item} que estará disponible
                  próximamente.
                </p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

// Main Dashboard Component (sin cambios)
const Dashboard = () => {
  const { darkMode } = useTheme();
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [activeContent, setActiveContent] = useState("dashboard");
  const { user, logout } = useAuth();

  const handleLogout = useCallback(async () => {
    await logout();
  }, [logout]);

  const renderContent = () => {
    switch (activeContent) {
      case "dashboard":
        return <DashboardContent />;
      case "perfil":
        return <Perfil />;
      case "usuarios":
        return <UsuariosTracker />;
      case "historialmedico":
        return <MedicalHistoryManager />;
      case "citas":
        return <MedicalAppointmentsManager />;
      case "nutricion":
        return <NutritionManager />;
      case "recomendaciones":
        return <RecommendationsManager />;
      case "actividadfiscia":
        return <PhysicalActivityManager />;
      case "alertas":
        return <AlertsManager />;
      default:
        return <GenericContent title={activeContent} />;
    }
  };

  return (
    <div
      className={`min-h-screen flex transition-all duration-300 ${
        darkMode ? "bg-gray-900" : "bg-gray-50"
      }`}
    >
      <Sidebar
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
        activeContent={activeContent}
        setActiveContent={setActiveContent}
        user={user}
        onLogout={handleLogout}
      />

      <div className="flex-1 flex flex-col lg:ml-72">
        <Header
          onToggleSidebar={() => setSidebarOpen(!sidebarOpen)}
          user={user}
          onLogout={handleLogout}
        />

        <main
          className={`
            flex-1 overflow-auto transition-all duration-300
            ${
              darkMode
                ? "bg-gradient-to-br from-gray-900 via-gray-900 to-gray-800"
                : "bg-gradient-to-br from-emerald-50/30 via-white to-blue-50/30"
            }
          `}
        >
          {renderContent()}
        </main>
      </div>
    </div>
  );
};

export default Dashboard;
