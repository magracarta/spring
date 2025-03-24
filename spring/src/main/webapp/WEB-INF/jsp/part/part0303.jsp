<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 부품 > 매입관리 > 매입정산관리 > null > null
-- 작성자 : 황다은
-- 최초 작성일 : 2024-05-21 14:17:42
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGrid;
        var authEditFile = false;
        var isExpand = true;

        $(document).ready(function () {
            createAUIGrid(); // 메인 그리드
            if ("${page.fnc.F05743_001}"=="Y") {
                authEditFile = true;
            }
            var hideList = ["pay_file_name_modi"];
            if(!authEditFile) {
                // 관리부는 대금지급청구서 미리보기만 가능
                AUIGrid.hideColumnByDataField(auiGrid, hideList);
            }
        });

        // 조회
        function goSearch() {
            if ($M.validation(document.main_form,
                {field: ["s_start_dt", "s_end_dt"]}) == false) {
                return;
            }

            var param = {
                "s_date_type" : $M.getValue("s_date_type"),
                "s_start_dt" : $M.getValue("s_start_dt"),
                "s_end_dt" : $M.getValue("s_end_dt"),
                "s_cust_name" : $M.getValue("s_cust_name"),
                "s_com_buy_group_cd" : $M.getValue("s_com_buy_group_cd"),
                "s_proc_status" : $M.getValue("s_proc_status")
            };
            _fnAddSearchDt(param, 's_start_dt', 's_end_dt');
            $M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method: 'get'},
                function (result) {
                    if(result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGrid, []);
                        AUIGrid.setGridData(auiGrid, result.list);
                        isExpand == true ?  fnExpandAll() : fnCollapseAll();
                    }
                }
            );
        }

        // 액셀다운로드
        function fnDownloadExcel() {
            fnExportExcel(auiGrid, "매입거래정산관리목록");
        }

        // 매입처조회
        function fnSearchClientComm() {
            var param = {
                's_cust_name' : $M.getValue('s_cust_name')
            };
            openSearchClientPanel('setSearchClientInfo', 'comm', $M.toGetParam(param));
        }

        // 매입처 조회 팝업 클릭 후 리턴
        function setSearchClientInfo(row) {
            $M.setValue("s_cust_name", row.cust_name);
        }

        // 펼침
        function fnExpandAll() {
            AUIGrid.expandAll(auiGrid);
            isExpand = true;
        }
        // 접힘
        function fnCollapseAll() {
            AUIGrid.collapseAll(auiGrid);
            isExpand = false;
        }

        // 파일 업로드
        function goUploadImg(rowIndex) {
            var gridData = AUIGrid.getGridData(auiGrid);

            var param = {
                upload_type: "DEAL",
                file_type: "both",
                file_ext_type : 'pdf#img',
                max_size : 5000
            };

            $M.setValue("row_index", rowIndex);

            openFileUploadPanel("setSaveFileInfo", $M.toGetParam(param));
        }

        // 대금지급청구서사진 미리보기 and 수정
        function fnPreview(fileSeq, rowIndex) {
            $M.setValue("row_index", rowIndex);
            var params = {
                file_seq : fileSeq,
                upload_type: "DEAL",
                file_type: "both",
                file_ext_type : 'pdf#img',
                max_size : 5000
            };

            openFileUploadPanel('setSaveFileInfo', $M.toGetParam(params));
        }

        // 파일 콜백
        function setSaveFileInfo(result) {
            AUIGrid.updateRow(auiGrid, { "pay_file_seq" : result.file_seq, pay_file_name: result.file_name}, $M.getValue('row_index'));
        }

        // 파일 삭제
        function fnRemoveFile(rowIndex) {
            AUIGrid.updateRow(auiGrid, { "pay_file_seq" : '0', pay_file_name: ''}, rowIndex);
        }

        // 대금지급청구서 저장
        function goFileSave(){
            var gridData = AUIGrid.getEditedRowItems(auiGrid); // 변경내역

            if(gridData.length < 1) {
                alert("저장할 파일이 존재하지 않습니다.");
                return;
            }

            var clientPayPlanDt = [];
            var custNoArr = [];
            var payFileSeq = [];

            for(var i=0; i<gridData.length; i++) {
                clientPayPlanDt.push(gridData[i].client_pay_plan_dt);
                custNoArr.push(gridData[i].cust_no);
                payFileSeq.push(gridData[i].pay_file_seq);
            }

            var param = {
                client_pay_plan_dt_str : $M.getArrStr(clientPayPlanDt),
                cust_no_str : $M.getArrStr(custNoArr),
                pay_file_seq_str : $M.getArrStr(payFileSeq)
            }

            $M.goNextPageAjaxSave(this_page + "/saveFile", $M.toGetParam(param), {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearch();
                    };
                }
            );
        }

        // 첨부서류 일괄다운로드
        function fnFileAllDownload() {
            var fileSeqArr = [];

            var allRows = AUIGrid.getGridData(auiGrid);

            for(var i = 0; i < allRows.length; i ++) {
                if(allRows[i].seq_depth == 1 && allRows[i].pay_file_seq != "" && allRows[i].pay_file_seq != 0) {
                    fileSeqArr.push(allRows[i].pay_file_seq);
                }
            }

            var zipFileName = '대금지급청구서 총 ' + (fileSeqArr.length) + '건';

            var paramObj = {
                'file_seq_str' : $M.getArrStr(fileSeqArr),
                'zip_file_name' : zipFileName
            }

            fileDownloadZip(paramObj);
        }

        // 그리드 생성
        function createAUIGrid() {
            var gridPros = {
                showRowNumColumn: true,
                showFooter : true,
                footerPosition : "top",
                selectionMode : "singleRow",
                wordWrap : true,
            }

            // 컬럼레이아웃
            var columnLayout = [
                {
                    headerText : "매입처",
                    dataField : "cust_name",
                    width : "170",
                    minWidth : "170",
                    editable : true,
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.cust_name : "";
                    },
                },
                {
                    dataField : "cust_no",
                    visible : false
                },
                {
                    headerText : "사업자등록번호",
                    dataField : "breg_no",
                    width : "100",
                    minWidth : "100",
                    editable : true,
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.breg_no : "";
                    },
                },
                {
                    headerText : "회계거래처코드",
                    dataField : "account_link_cd",
                    width : "100",
                    minWidth : "100",
                    editable : true,
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.account_link_cd : "";
                    },
                },
                {
                    headerText: "전표번호",
                    dataField: "inout_doc_no",
                    width : "130",
                    minWidth : "130",
                    style : "aui-center aui-link",
                    labelFunction : function(rowIndex, columnIndex, value, headerText, item) {
                        var docNo = value;
                        return docNo == "" ? "" : docNo.substring(4, 16);
                    }
                },
                {
                    headerText: "정산예정일",
                    dataField: "client_pay_plan_dt",
                    dataType : "date",
                    formatString : "yy-mm-dd",
                    width : "130",
                    minWidth : "130",
                    style : "aui-center",
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        if(item.seq_depth == "2") {
                            return "aui-link";
                        };
                        return null;
                    }
                },
                {
                    headerText: "정산완료일",
                    dataField: "pay_dt",
                    dataType : "date",
                    formatString : "yy-mm-dd",
                    width : "130",
                    minWidth : "130",
                    style : "aui-center"
                },
                {
                    headerText: "처리상태",
                    dataField: "proc_status",
                    width : "110",
                    minWidth : "110",
                    style: "aui-center",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.proc_status == "01" ? "정산요청" : "정산완료";
                    },
                },
                {
                    headerText : "금액",
                    dataField : "total_amt",
                    dataType : "numeric",
                    formatString : "#,##0",
                    width : "130",
                    minWidth : "130",
                    style : "aui-right",
                    // 합계금액에만 출금전표팝업 나오게 하기
                    styleFunction :  function(rowIndex, columnIndex, value, headerText, item, dataField) {
                        if(item.seq_depth == "1") {
                            return "aui-popup";
                        };
                        return null;
                    }
                },
                {
                    headerText : "대금지급청구서",
                    dataField: "pay_file_name",
                    editable: true,
                    width : "200",
                    minWidth : "200",
                    editable: false,
                    renderer : { // HTML 템플릿 렌더러 사용
                        type : "TemplateRenderer"
                    },
                    labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
                        if(item.seq_depth == "1"){
                            if(item.pay_file_seq == null || item.pay_file_seq == 0 ) {
                                if (!authEditFile) {
                                    return ""
                                }
                            } else {
                                var template =
                                    '<div>' + '<span style="color:dodgerblue; cursor: pointer; text-decoration: underline;" onclick="javascript:openFileViewerPanel(' + item.pay_file_seq + ',' + rowIndex + ');">' + item.pay_file_name + '</span></div>';
                                return template;
                            }
                        }
                    }
                },
                {
                    headerText : "대금지급청구서 수정",
                    dataField: "pay_file_name_modi",
                    editable: true,
                    width : "200",
                    minWidth : "200",
                    editable: false,
                    renderer : { // HTML 템플릿 렌더러 사용
                        type : "TemplateRenderer"
                    },
                    labelFunction : function( rowIndex, columnIndex, value, dataField, item) {
                        if(item.seq_depth == "1"){
                            if(item.pay_file_seq == null || item.pay_file_seq == 0 ) {
                                return '<button type="button" class="btn btn-primary-gra" style="width: 40%; max-width: 90px;" onclick="javascript:goUploadImg(' + rowIndex + ');">파일추가</button>';
                            } else {
                                var template =
                                    '<div>' + '<span style="color:dodgerblue; cursor: pointer; text-decoration: underline;" onclick="javascript:fnPreview(' + item.pay_file_seq + ',' + rowIndex + ');">' + item.pay_file_name + '</span>';
                                template += '<button type="button" style="height: 18px" id="fileRemoveBtn" class="btn-default ml5" onclick="javascript:fnRemoveFile(' + rowIndex + ')"><i class="material-iconsclose font-16 text-default"></i></button></div>';
                                return template;
                            }
                        }
                    }
                },
                {
                    headerText: "은행명",
                    dataField: "bank_name",
                    width : "100",
                    minWidth : "100",
                    style: "aui-center",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.bank_name : "";
                    }
                },
                {
                    headerText: "계좌번호",
                    dataField: "account_no",
                    width : "150",
                    minWidth : "150",
                    style: "aui-center",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.account_no : "";
                    }
                },
                {
                    headerText: "예금주",
                    dataField: "client_deposit_name",
                    width : "130",
                    minWidth : "130",
                    style: "aui-center",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.client_deposit_name : "";
                    }
                },
                {
                    headerText: "지불조건",
                    dataField: "out_case_name",
                    width : "110",
                    minWidth : "110",
                    style: "aui-center",
                    labelFunction : function( rowIndex, columnIndex, value, headerText, item ) {
                        return item.seq_depth == "1" ? item.out_case_name : "";
                    }
                },
                {
                    headerText : "seq_depth",
                    dataField : "seq_depth",
                    visible : false
                },
                {
                    headerText : "거래처정산번호",
                    dataField : "client_pay_seq",
                    visible : false
                },
                {
                    headerText: "지급전표번호",
                    dataField: "pay_inout_doc_no",
                    visible: false
                },
                {
                    headerText: "전표일자",
                    dataField: "inout_dt",
                    visible: false
                }
            ];
            // 푸터레이아웃
            var footerColumnLayout = [
                {
                    labelText : "합계",
                    positionField : "proc_status",
                    style: "aui-center aui_footer"
                },
                {
                    dataField : "total_amt",
                    positionField : "total_amt",
                    // operation : "SUM",
                    formatString : "#,##0",
                    style : "aui-right aui-footer",
                    expFunction : function(columnValues) {  // 첫번째 depth의 합계
                        var sum = 0;
                        var treeData = AUIGrid.getTreeGridData(auiGrid);
                        treeData.forEach(function(v) {
                            sum += v.total_amt;
                        });
                        return sum;
                    }
                },
            ];

            // 실제 그리드 생성
            auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

            // 푸터 객체 세팅
            AUIGrid.setFooter(auiGrid, footerColumnLayout);
            // 그리드 갱신
            AUIGrid.setGridData(auiGrid, []);

            AUIGrid.bind(auiGrid, "cellClick", function (event) { // 전표번호 클릭 시 [부품매입처리상세]팝업호출
                var params = {};
                var popupOption = "";
                if(event.dataField == "inout_doc_no" && event.item.seq_depth == "2") {
                    params = {
                        "inout_doc_no" : event.item.inout_doc_no,
                        "call_page_seq" : 5743,
                    };
                    popupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1060, height=690, left=0, top=0";
                    $M.goNextPage("/part/part0302p05", $M.toGetParam(params), {popupStatus : popupOption});

                } else if(event.dataField == "client_pay_plan_dt" && event.item.seq_depth == "2") { // 정산요청 클릭 시 [매입처거래원장상세]팝업 호출
                    params = {
                        "s_cust_no": event.item["cust_no"],
                        "s_inout_dt": event.item["inout_dt"],
                        // "s_end_dt": event.item["inout_dt"]
                    };
                    $M.goNextPage("/part/part0303p01", $M.toGetParam(params), {popupStatus: popupOption});
                } else if(event.dataField == "total_amt" && event.item.seq_depth == "1") {   // 금액(1depth의 금액) 클릭 시 [입출금전표등록]팝업 호출
                    var inoutDocNoStr = [];
                    var params = {};
                    var callUrl;

                    // 파라미터에 하위 전표번호 전달
                    for(var i = 0; i<event.item["children"].length; i++) {
                        inoutDocNoStr.push(event.item.children[i].inout_doc_no);
                    }
                    if(event.item.proc_status == "01") {
                        // 입출금전표처리
                        params = {
                            "cust_no" : event.item["cust_no"],
                            "inout_type_io" : "O",
                            "total_amt" : Math.ceil(event.item["total_amt"]),   // 22556.이원영파트장님이 올림으로 설정 요청
                            "popup_yn" : "Y",
                            "call_page_seq" : $M.getValue("page_seq"),
                            "inout_doc_no_str" : inoutDocNoStr
                        };
                        callUrl = '/cust/cust020301';
                    } else {
                        // 입출금전표처리 상세
                        params = {
                            "inout_doc_no" : event.item["pay_inout_doc_no"]
                        };
                        callUrl = '/cust/cust0203p01';
                    }


                    $M.goNextPage(callUrl, $M.toGetParam(params), {popupStatus : popupOption});
                }
            })
        }

    </script>
</head>
<body>
<form id="main_form" name="main_form">
    <input type="hidden" id="page_seq" name="page_seq" value="${info.page_seq}">
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
                            <col width="100px">
                            <col width="255px">
                            <col width="55px">
                            <col width="130px">
                            <col width="60px">
                            <col width="170px">
                            <col width="60px">
                            <col width="80px">
                            <col width="">
                        </colgroup>
                        <tbody>
                        <tr>
                            <td>
                                <select class="form-control" name="s_date_type" id="s_date_type">
                                    <option value="client_pay_plan_dt" selected="selected">정산예정일</option>
                                    <option value="pay_dt">정산완료일</option>
                                </select>
                            </td>
                            <td>
                                <div class="form-row inline-pd widthfix">
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateformat="yyyy-MM-dd" required="required" alt="조회 시작일">
                                        </div>
                                    </div>
                                    <div class="col-auto">~</div>
                                    <div class="col-5">
                                        <div class="input-group">
                                            <input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateformat="yyyy-MM-dd" required="required" alt="조회 종료일">
                                        </div>
                                    </div>
                                    <jsp:include page="/WEB-INF/jsp/common/searchDtType.jsp">
                                        <jsp:param name="st_field_name" value="s_start_dt"/>
                                        <jsp:param name="ed_field_name" value="s_end_dt"/>
                                        <jsp:param name="click_exec_yn" value="Y"/>
                                        <jsp:param name="exec_func_name" value="goSearch();"/>
                                    </jsp:include>
                                </div>
                            </td>
                            <th>매입처</th>
                            <td>
                                <div class="input-group">
                                    <input type="text" class="form-control border-right-0" placeholder="" id="s_cust_name" name="s_cust_name" value="">
                                    <button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:fnSearchClientComm();"><i class="material-iconssearch"></i></button>
                                </div>
                            </td>
                            <th>업체그룹</th>
                            <td>
                                <input class="form-control" style="width: 99%;" type="text" id="s_com_buy_group_cd" name="s_com_buy_group_cd" easyui="combogrid"
                                       easyuiname="groupList" panelwidth="250" idfield="code" textfield="code_desc" multi="Y"/>
<%--                                <select class="form-control" id="s_com_buy_group_cd" name="s_com_buy_group_cd">--%>
<%--                                    <option value="">- 전체 -</option>--%>
<%--                                    <c:forEach var="item" items="${codeMap['COM_BUY_GROUP']}">--%>
<%--                                        <option value="${item.code_value}">${item.code_desc}</option>--%>
<%--                                    </c:forEach>--%>
<%--                                </select>--%>
                            </td>
                            <th>처리상태</th>
                            <td>
                                <select class="form-control" id="s_proc_status" name="s_proc_status">
                                    <option value="">전체</option>
                                    <option value="01" selected="selected">정산요청</option>
                                    <option value="02">정산완료</option>
                                </select>
                            </td>
                            <td>
                                <button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch();">조회</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <!-- /검색영역 -->
                <!-- 그리드 타이틀, 컨트롤 영역 -->
                <div class="title-wrap mt10">
                    <h4>조회결과</h4>
                    <div class="btn-group">
                        <div class="right">
                            <div class="table-attfile" style="display: inline-block; margin-left: 5px;  float: right;">
                                <button type="button" class="btn btn-primary-gra ml10"  onclick="javascript:fnFileAllDownload();">파일일괄다운로드</button>
                            </div>
                            <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
                        </div>
                    </div>
                </div>
                <!-- /그리드 타이틀, 컨트롤 영역 -->
                <div id="auiGrid" style="height: 555px; margin-top: 5px;"></div>
                <!-- 그리드 서머리, 컨트롤 영역 -->
                <div class="btn-group mt5">
                    <div class="left">
                        총 <strong id="total_cnt" class="text-primary">0</strong>건
                    </div>
                    <c:if test="${page.fnc.F05743_001 eq 'Y'}">
                        <div class="right">
                            <button type="button" class="btn btn-info" id="fileSaveBtn" onclick="javascript:goFileSave();">파일저장</button>
                        </div>
                    </c:if>
                </div>
                <!-- /그리드 서머리, 컨트롤 영역 -->
            </div>
        </div>
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
    <!-- /contents 전체 영역 -->
</form>

</body>
</html>
