<%@ page contentType="text/html;charset=utf-8" language="java" %>
<jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/>
<%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>
<%@ taglib uri="http://www.springframework.org/tags/form" prefix="form" %>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 업무자율배정
-- 작성자 : 박동훈
-- 최초 작성일 : 2024-12-05 09:54:29
-- 업무자율배정 리스트
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">

        var auiGrid;
        var page = 1;
        var moreFlag = "N";
        var isLoading = false;
        var dataFieldName = []; // 펼침 항목(create할때 넣음)

        $(document).ready(function () {
            fnInit();
            // AUIGrid 생성
            createAUIGrid();

            goSearch();
        });

        function fnInit() {
            <%--var org = ${orgBeanJson};--%>
            <%--if (org.org_gubun_cd != "BASE") {--%>
            <%--    $("#s_org_code").prop("disabled", true);--%>
            <%--}--%>
        }

        // 엔터키 이벤트
        function enter(fieldObj) {
            var field = ["s_reg_mem_name", "s_assign_id"];
            $.each(field, function () {
                if (fieldObj.name == this) {
                    goSearch();
                }
            });
        }

        // 펼침
        function fnChangeColumn(event) {
            var data = AUIGrid.getGridData(auiGrid);
            var target = event.target || event.srcElement;
            if(!target)	return;

            var dataField = target.value;
            var checked = target.checked;

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];

                if(checked) {
                    AUIGrid.showColumnByDataField(auiGrid, dataField);
                } else {
                    AUIGrid.hideColumnByDataField(auiGrid, dataField);
                }
            }
        }

        function goSearch() {
            // 조회 버튼 눌렀을경우 1페이지로 초기화
            page = 1;
            moreFlag = "N";
            fnSearch(function (result) {
                AUIGrid.setGridData(auiGrid, result.list);
                $("#total_cnt").html(result.total_cnt);
                $("#curr_cnt").html(result.list.length);
                if (result.more_yn == 'Y') {
                    moreFlag = "Y";
                    page++;
                }
            });
        }

        // 조회
        function fnSearch(successFunc) {
            var frm = document.main_form;
            //validationcheck
            if ($M.validation(frm,
                {field: ["s_start_dt", "s_end_dt"]}) == false) {
                return;
            }

            if ($M.checkRangeByFieldName("s_start_dt", "s_end_dt", true) == false) {
                return;
            }

            var param = {
                "s_start_dt": $M.getValue("s_start_dt"),
                "s_end_dt": $M.getValue("s_end_dt"),
                "s_org_code": $M.getValue("s_org_code"),
                "s_reg_mem_name": $M.getValue("s_reg_mem_name"),
                "s_self_assign_type_cd": $M.getValue("s_self_assign_type_cd"),
                "s_job_div": $M.getValue("s_job_div"),
                "s_self_assign_gubun_cd": $M.getValue("s_self_assign_gubun_cd"),
                "s_assign_id": $M.getValue("s_assign_id"),
                "s_complete_div": $M.getValue("s_complete_div"),
                "s_assign_status": $M.getValue("s_assign_status"),
                "s_masking_yn": $M.getValue("s_masking_yn") == "Y" || ${page.add.POS_UNMASKING ne 'Y'} ? "Y" : "N",
                "page": page,
                "rows": $M.getValue("s_rows")
            };
            // _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'GET'},
                function (result) {
                    isLoading = false;
                    if (result.success) {
                        successFunc(result);
                        var spanHtml = "<span>예약확정현황 > 접수 후</span>";
                        for(var i = 0 ; i < result.statusList.length ; i++){
                            if(result.statusList[i].timediff != "0"){
                                if(result.statusList[i].timediff != "121"){
                                    spanHtml += "<span>"+result.statusList[i].timediff+"분 이내 : "+result.statusList[i].cnt+" </span>"
                                }else {
                                    spanHtml += "<span>120분 경과 : "+result.statusList[i].cnt+" </span>"
                                }
                            }else {
                                spanHtml += "<span>미 배정 : "+result.statusList[i].cnt+" </span>"
                            }
                        }
                        $("#statusText").html(spanHtml);
                    }
                }
            );
        }

        // 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
        function fnScollChangeHandelr(event) {
            if (event.position == event.maxPosition && moreFlag == "Y" && isLoading == false) {
                goMoreData();
            }
        }

        function goMoreData() {
            fnSearch(function (result) {
                result.more_yn == "N" ? moreFlag = "N" : page++;
                if (result.list.length > 0) {

                    AUIGrid.appendData("#auiGrid", result.list);
                    $("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
                }
            });
        }

        // 엑셀 다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "정비지시서");
        }

        // 등록페이지 호출
        function goNew() {
            var popupOption = "";
            var params = {
                "s_popup_yn": "Y"
            };

            $M.goNextPage('/mmyy/mmyy0114p01', $M.toGetParam(params), {popupStatus: popupOption});
        }

        //그리드생성
        function createAUIGrid() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                enableFilter :true,
                rowStyleFunction : function(rowIndex, item) {
                    var style = "";
                    if(item.self_assign_proc_date == "") { // 기본
                        style = "aui-status-default";
                    } else { // 완료
                        style = "aui-status-complete";
                    }

                    return style;
                }
            };

            var columnLayout = [
                {
                    headerText: "접수 번호",
                    dataField: "self_assign_no",
                    width : "90",
                    minWidth : "45",
                    style: "aui-center aui-popup",
                    filter : {
		                  showIcon : true
		            },
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        var ret = "";
                        if (value != null && value != "") {
                            ret = value.split("-");
                            ret = ret[1]+"-"+ret[2];
                            ret = ret.substr(2, ret.length);
                        }
                        return ret;
                    },
                },
                {
                    headerText: "접수 일시",
                    dataField: "reg_date",
                    dataType: "date",
                    formatString: "yy-mm-dd HH:MM",
                    width : "100",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText: "접수자",
                    dataField: "reg_mem_name",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "접수센터",
                    dataField: "self_assign_org_name",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "접수분류",
                    dataField: "self_assign_type_name",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "입고일자",
                    dataField: "in_dt",
                    dataType: "date",
                    formatString: "yy-mm-dd",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText: "정비구분",
                    dataField: "job_type_name",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "접수구분",
                    dataField: "self_assign_gubun_name",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    },
                },
                {
                    headerText: "고객명",
                    dataField: "cust_name",
                    width : "130",
                    minWidth : "130",
                    style: "aui-center aui-popup",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "연락처",
                    dataField: "cust_hp_no",
                    width : "110",
                    minWidth : "110",
                    style: "aui-center",
                    editable: true,
                    editRenderer: {
                        type: "InputEditRenderer",
                        onlyNumeric: true,
                    },
                    filter : {
                        showIcon : true
                    },
                    labelFunction: function (rowIndex, columnIndex, value, headerText, item) {
                        if (String(value).length > 0) {
                            // 전화번호에 대시 붙이는 정규식으로 표현
                            return value.replace(/(^02.{0}|^01.{1}|[0-9]{3})([0-9]+)([0-9]{4})/, "$1-$2-$3");
                        }
                        return value;
                    }
                },
                {
                    headerText: "모델명",
                    dataField: "machine_name",
                    width : "120",
                    minWidth : "120",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText: "차대번호",
                    dataField: "body_no",
                    width : "160",
                    minWidth : "160",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
                {
                    dataField: "assignBtn",
                    headerText: "찜 여부",
                    width : "70",
                    minWidth : "70",
                    renderer: {
                        type: "ButtonRenderer",
                        onClick: function (event) {
                            if(event.item["self_assign_org_code"] != "${SecureUser.org_code}"){
                                alert("타 센터 업무는 찜 하실 수 없습니다.");
                                return false;
                            }
                            var msg = "찜 하시겠습니까?";
                            var params = {
                                "s_self_assign_no": event.item["self_assign_no"],
                                "assign_date" : $M.getCurrentDate("yyyy-MM-dd HH:mm:ss"),
                                "s_job_report_no" : event.item["job_report_no"]
                            };
                            var popupOption = "";
                            $M.goNextPageAjaxMsg(msg,'/mmyy/mmyy0114/assignUpdate', $M.toGetParam(params), {popupStatus: popupOption},
                                function (result) {
                                    isLoading = false;
                                    if (result.success) {
                                        window.location.reload();
                                    }
                                });
                        },
                        disabledFunction: function (rowIndex, columnIndex, value, item, dataField) {
                            // 배정시 비활성화
                            if(item.assign_mem_no != "" || item.self_assign_proc_date != "") {
                                return true;
                            }
                            return false;
                        }
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item){
                        if(item.assign_mem_no != "" || item.self_assign_proc_date != "") {
                            return "완료";
                        }else {
                            return "찜 하기";
                        }
                    },
                    style: "aui-center"
                },
                {
                    headerText: "배정자",
                    dataField: "assign_mem_name",
                    width : "70",
                    minWidth : "70",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: '확정일시',
                    dataField: "div_confirm_date",
                    dataType: "date",
                    formatString: "yy-mm-dd HH:MM",
                    width : "100",
                    minWidth : "100",
                    style: "aui-center",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "지시서(계약서)",
                    dataField: "div_report_no",
                    width : "120",
                    minWidth : "120",
                    style: "aui-center aui-popup",
                    filter : {
		                  showIcon : true
		            }
                },
                {
                    headerText: "일지",
                    dataField: "as_no",
                    style: "aui-center aui-popup",
                    width : "120",
                    minWidth : "120",
                    filter : {
		                  showIcon : true
		            },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item){
                        if(item.as_count == 0) {
                            return "";
                        }else {
                            return item.as_no;
                        }
                    }
                },
                {
                    headerText: "예약확정현황",
                    dataField: "assign_status",
                    width : "140",
                    minWidth : "140",
                    style: "aui-left",
                    filter : {
                        showIcon : true
                    },
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item){
                        if(item.div_confirm_date != "") {
                            var confirmDate = new Date(item.div_confirm_date);
                            var regDate = new Date(item.reg_date);
                            var diffTime = (confirmDate - regDate) / 1000 / 60 ;

                            if(diffTime < 31){
                                return "접수 후 30분 이내 확정"
                            }else if(diffTime < 61){
                                return "접수 후 60분 이내 확정"
                            }else if(diffTime < 91){
                                return "접수 후 90분 이내 확정"
                            }else if(diffTime < 121){
                                return "접수 후 120분 이내 확정"
                            }else if(diffTime > 120){
                                return "접수 후 120분 경과 후 확정"
                            }
                        }else {
                            return "접수 후 미확정";
                        }
                    }
                },
                {
                    headerText: "처리일시",
                    dataField: "self_assign_proc_date",
                    dataType: "date",
                    formatString: "yy-mm-dd HH:MM",
                    width : "100",
                    minWidth : "100",
                    style: "aui-center",
                    filter : {
                        showIcon : true
                    }
                },
            ];

            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);
            AUIGrid.setGridData(auiGrid, []);
            $("#auiGrid").resize();

            // 상세팝업
            AUIGrid.bind(auiGrid, "cellClick", function (event) {
                if (event.dataField == "self_assign_no") {
                    var params = {
                        "s_self_assign_no": event.item["self_assign_no"]
                    };
                    var popupOption = "";
                    $M.goNextPage('/mmyy/mmyy0114p02', $M.toGetParam(params), {popupStatus: popupOption});
                }
                if(event.dataField == "cust_name") {
                    var custNo = event.item["cust_no"];
                    if (custNo != "") {
                        var param = {
                            cust_no : custNo
                        }
                        $M.goNextPage("/cust/cust0102p01", $M.toGetParam(param), {popupStatus : ""});
                    }
                }
                if(event.dataField == "div_report_no") {
                    if(event.item["self_assign_type_cd"] == "01"){
                        var jobReportNo = event.item["job_report_no"];
                        if (jobReportNo != "") {
                            var params = {
                                "s_job_report_no": jobReportNo,
                                "s_self_assign_no" : event.item["self_assign_no"]
                            };
                            var popupOption = "";
                            $M.goNextPage('/serv/serv0101p01', $M.toGetParam(params), {popupStatus: popupOption});
                        }
                    }else {
                        var rentalDocNo = event.item["rental_doc_no"];
                        if (rentalDocNo != "") {
                            var params = {
                                "rental_doc_no": rentalDocNo,
                                "s_self_assign_no" : event.item["self_assign_no"]
                            };
                            var popupOption = "scrollbars=no, resizable=yes, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1500, height=730, left=0, top=0";

                            if("01,02,03".indexOf(event.item["rental_status_cd"]) > -1 ){
                                $M.goNextPage('/rent/rent0101p01', $M.toGetParam(params), {popupStatus: popupOption});
                            }else if (event.item.out_dt == "") {// 출고, 출고요청이면 렌탈출고/회수처리 //` 연장, 회수면이면 렌탈연장/회수처리`
                                $M.goNextPage("/rent/rent0102p01", $M.toGetParam(params), {popupStatus : popupOption});
                            } else {
                                if (event.item.extend_yn == "Y" || event.item.return_dt != "") {
                                    $M.goNextPage('/rent/rent0102p02', $M.toGetParam(params), {popupStatus : popupOption});
                                } else {
                                    $M.goNextPage('/rent/rent0102p01', $M.toGetParam(params), {popupStatus : popupOption});
                                }
                            }

                        }
                    }
                }

                if(event.dataField == "as_no") {
                    var asNo = event.item["as_no"];
                    if (asNo != "") {
                        var params = {
                            "s_as_no": asNo,
                            "s_job_report_no" : event.item["job_report_no"],
                        };
                        var popupOption = "";
                        $M.goNextPage('/serv/serv0102p01', $M.toGetParam(params), {popupStatus: popupOption});
                    }
                }
            });

            AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);

            // 펼치기 전에 접힐 컬럼 목록
            var auiColList = AUIGrid.getColumnInfoList(auiGrid);
            for (var i = 0; i <auiColList.length; ++i) {
                if (auiColList[i].headerStyle != null && auiColList[i].headerStyle == "aui-fold") {
                    dataFieldName.push(auiColList[i].dataField);
                }
            }

            for (var i = 0; i < dataFieldName.length; ++i) {
                var dataField = dataFieldName[i];
                AUIGrid.hideColumnByDataField(auiGrid, dataField);
            }
        }
    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <div class="layout-box">
        <!-- contents 전체 영역 -->
        <div class="content-wrap">
            <div class="content-box">
                <!-- 메인 타이틀 -->
                <div class="main-title">
                    <jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
                </div>
                <!-- /메인 타이틀 -->
                <div class="contents">
                    <!-- 검색영역 -->
                    <div class="search-wrap">
                        <table class="table">
                            <colgroup>
                                <col width="90px">
                                <col width="260px">
                                <col width="40px">
                                <col width="100px">
                                <col width="70px">
                                <col width="100px">
                                <col width="90px">
                                <col width="100px">
                                <col width="90px">
                                <col width="100px">
                                <col width="90px">
                                <col width="100px">
                                <col width="70px">
                                <col width="100px">
                                <col width="90px">
                                <col width="100px">
                                <col width="90px">
                                <col width="100px">
                                <col width="">
                            </colgroup>
                            <tbody>
                            <tr>
                                <th>접수일자</th>
                                <td colspan="" style="min-width: 260px">
                                    <div class="form-row inline-pd">
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="시작일" value="${inputParam.s_start_dt}">
                                            </div>
                                        </div>
                                        <div class="col-auto">~</div>
                                        <div class="col-5">
                                            <div class="input-group dev_nf">
                                                <input type="text" class="form-control border-right-0 essential-bg calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" alt="종료일" required="required" value="${inputParam.s_end_dt}">
                                            </div>
                                        </div>
                                    </div>
                                </td>
                                <th>센터</th>
                                <td>
                                    <select class="form-control" name="s_org_code" id="s_org_code" <c:if test="${page.fnc.F06043_001 eq 'Y'}">disabled</c:if> >
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="list" items="${orgCodeList}">
                                            <c:if test="${list.code_value ne '5010' and list.code_value ne '6000' and list.code_v2 eq 'Y'}">
                                                <option value="${list.code_value}" <c:if test="${list.code_value eq orgBean.org_code}">selected</c:if> >${list.code_name}</option>
                                            </c:if>
                                        </c:forEach>
                                    </select>
                                </td>
                                <th>접수자</th>
                                <td>
                                    <input type="text" id="s_reg_mem_name" name="s_reg_mem_name" class="form-control">
                                </td>
                                <th>접수분류</th>
                                <td>
                                    <select class="form-control" name="s_self_assign_type_cd" id="s_self_assign_type_cd">
                                        <option value="">- 전체 -</option>
                                        <option value="01">정비</option>
                                        <option value="02">렌탈계약</option>
                                        <option value="03">렌탈출고</option>
                                        <option value="04">렌탈회수</option>
                                    </select>
                                </td>
                                <th>접수구분</th>
                                <td>
                                    <select class="form-control" name="s_self_assign_gubun_cd" id="s_self_assign_gubun_cd">
                                        <option value="">- 전체 -</option>
                                        <option value="01">ERP</option>
                                        <option value="02">APP</option>
                                    </select>
                                </td>
                                <th>업무분류</th>
                                <td>
                                    <input type="text"
                                           id="s_job_div"
                                           name="s_job_div"
                                           easyui="combogrid"
                                           header="Y"
                                           easyuiname="jobTypeCdList"
                                           panelwidth="100"
                                           maxheight="300"
                                           textfield="code_name"
                                           multi="Y"
                                           idfield="code_value" />
                                </td>
                                <th>배정자</th>
                                <td>
                                    <input type="text" id="s_assign_id" name="s_assign_id" class="form-control">
                                </td>
                                <th>처리여부</th>
                                <td>
                                    <select class="form-control" name="s_complete_div" id="s_complete_div">
                                        <option value="">- 전체 -</option>
                                        <option value="1">미 배정</option>
                                        <option value="2">배정완료</option>
                                        <option value="3">처리완료</option>
                                        <option value="4">완결</option>
                                    </select>
                                </td>
                                <th>배정현황</th>
                                <td>
                                    <select class="form-control" name="s_assign_status" id="s_assign_status">
                                        <option value="">- 전체 -</option>
                                        <option value="30">접수 후 30분 이내 확정</option>
                                        <option value="60">접수 후 60분 이내 확정</option>
                                        <option value="90">접수 후 90분 이내 확정</option>
                                        <option value="120">접수 후 120분 이내 확정</option>
                                        <option value="121">접수 후 120분 경과 후 확정</option>
                                        <option value="0">접수 후 미 확정</option>
                                    </select>
                                </td>
                                <td>
                                    <button type="button" class="btn btn-important mr10" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                    <!-- /검색영역 -->
                    <!-- 그리드 타이틀, 컨트롤 영역 -->
                    <div class="title-wrap mt10">
                        <h4>조회결과</h4>
                        <%--<div class="text-warning" style="margin-left:10px; width:70%;">
                            ※ 업무 플로우는 고객신청/접수 -> 배정 -> 예약확정 -> 지시서 작성 -> 완료 순서입니다.
                        </div>--%>
                        <div class="btn-group">
                            <div class="right">
                                    <div class="form-check form-check-inline">
                                        <div class="comment-text" id="statusText">

                                        </div>
                                        &nbsp;&nbsp;
                                        <c:if test="${page.add.POS_UNMASKING eq 'Y'}">
                                            <input class="form-check-input" type="checkbox" id="s_masking_yn" name="s_masking_yn"<c:if test="${page.masking_default_yn eq 'Y'}" > checked</c:if> value="Y" >
                                            <label class="form-check-input" for="s_masking_yn">마스킹 적용</label>
                                        </c:if>
<%--                                        <label for="s_toggle_column" style="color:black;">--%>
<%--                                            <input type="checkbox" id="s_toggle_column" onclick="javascript:fnChangeColumn(event)">펼침--%>
<%--                                        </label>--%>
                                    </div>
                                <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                            </div>
                        </div>
                    </div>
                    <!-- /그리드 타이틀, 컨트롤 영역 -->
                    <div id="auiGrid" style="margin-top: 5px; height: 500px;"></div>
                    <div class="btn-group mt5">
                        <div class="left">
                            <jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
                        </div>
                        <div class="right">
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                        </div>
                    </div>
                </div>
            </div>
            <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
        </div>
        <!-- /contents 전체 영역 -->
    </div>
</form>
</body>
</html>