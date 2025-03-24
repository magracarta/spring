<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 :
-- 작성자 : 손광진
-- 최초 작성일 : 2022-10-13 14:23:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
</head>
<script type="text/javascript">

    var auiGrid;

    $(document).ready(function() {
        createAUIGrid();
    });

    //그리드생성
    function createAUIGrid() {
        var gridPros = {
            rowIdField: "_$uid",
            height: 555,
        };

        var columnLayout = [
            {
                headerText: "고객명",
                dataField: "cust_name",
                width : "110",
                minWidth : "120",
                style: "aui-center aui-popup"
            },
            {
                dataField: "cust_no",
                visible: false
            },
            {
                dataField: "cust_counsel_seq",
                visible: false
            },
            {
                dataField: "consult_type_cd",
                visible: false
            },
            {
                headerText: "회원구분",
                dataField: "cust_type_name",
                width : "70",
                minWidth : "60",
                style: "aui-center"
            },
            {
                headerText: "고객등급",
                dataField: "show_cust_grade_cd_str",
                width : "70",
                minWidth : "60",
                style: "aui-center"
            },
            {
                headerText: "생일",
                dataField: "birth_dt",
                dataType: "date",
                width : "70",
                minWidth : "60",
                style: "aui-center",
                formatString: "yy-mm-dd"
            },
            {
                headerText: "휴대폰",
                dataField: "hp_no",
                width : "110",
                minWidth : "100",
                style: "aui-center"
            },
            {
                headerText: "주소",
                dataField: "addr",
                width : "280",
                minWidth : "170",
                style: "aui-left"
            },
            {
                headerText: "마케팅",
                dataField: "sale_mem_name",
                width : "70",
                minWidth : "60",
                style: "aui-center"
            },
            {
                headerText: "서비스",
                dataField: "service_mem_name",
                width : "70",
                minWidth : "60",
                style: "aui-center"
            },
            {
                dataField: "machine_plant_seq",
                visible: false
            },
            {
                headerText: "모델구분",
                dataField: "cust_machine_type",
                width : "115",
                minWidth : "110",
                style: "aui-center",
                labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                    if (value == 'OWN') {
                        return "보유모델";
                    } else if (value == 'CON') {
                        return "상담모델";
                    } else {
                        return "";
                    }
                }
            },
            {
                headerText: "모델명",
                dataField: "machine_name",
                width : "115",
                minWidth : "110",
                style: "aui-center"
            },
            {
                headerText: "안건상담일",
                dataField: "consult_dt_max",
                dataType: "date",
                width : "70",
                minWidth : "60",
                style: "aui-center",
                formatString: "yy-mm-dd"
            },
            {
                dataField: "consult_dt_min",
                dataType: "date",
                formatString: "yy-mm-dd",
                visible: false
            },
            {
                headerText: "상담횟수",
                dataField: "consult_cnt",
                style: "aui-center",
                width : "70",
                minWidth : "60"
            },
            {
                headerText: "미결일자",
                dataField: "uncomplete_dt",
                dataType: "date",
                formatString: "yy-mm-dd",
                width : "70",
                minWidth : "60",
                style: "aui-center"
            },
            {
                headerText: "미결수",
                dataField: "uncomplete_cnt",
                style: "aui-center",
                width : "70",
                minWidth : "60"
            },
            {
                headerText: "지역",
                dataField: "area_si",
                style: "aui-center",
                width : "60",
                minWidth : "50"
            },
        ];

        auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
        AUIGrid.setGridData(auiGrid, ${list});
        $("#auiGrid").resize();

        AUIGrid.bind(auiGrid, "cellClick", function (event) {
            if (event.dataField == 'cust_name') {
                try {
                    opener.${inputParam.parent_js_name}(event.item);
                    window.close();
                } catch(e) {
                    alert('호출 페이지에서 ${inputParam.parent_js_name}(row) 함수를 구현해주세요.');
                }
            }
        });
    }

    //팝업 끄기
    function fnClose() {
        window.close();
    }

</script>
<body class="bg-white class">
<form id="main_form" name="main_form">
    <!-- 팝업 -->
    <div class="popup-wrap width-100per">
        <!-- 타이틀영역 -->
        <div class="main-title">
            <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
        </div>
        <!-- /타이틀영역 -->
        <div class="content-wrap">
            <div class="title-wrap">
                <h4>상담내역</h4>
            </div>
            <!-- /검색조건 -->
            <!-- 검색결과 -->

            <div id="auiGrid" style="margin-top: 5px; height: 400px;"></div>

            <div class="btn-group mt5">
                <div class="right">
                    <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                </div>
            </div>
            <!-- /검색결과 -->
        </div>
    </div>
</form>
<!-- /팝업 -->

</body>
</html>