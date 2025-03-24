<%@ page contentType="text/html;charset=utf-8" language="java"%><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 트러블슈팅 관리 > null > null
-- 작성자 : 황다은
-- 최초 작성일 : 2024-06-11 09:24:48
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
    <jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
    <script type="text/javascript">
        var auiGridLeft;
        var auiGridCheck;
        var auiGridRight;
        var rowIndex;

        var reFileId;
        // 점검상세 리스트
        var listCnt = 0;

        // 첨부파일의 index 변수
        var filesIndex = 1;
        // 첨부할 수 있는 파일의 개수
        var fileCount = 5;

        $(document).ready(function() {
            createAUIGridLeft();
            createAUIGridRight();
            createAUIGridCheck();
        });

        //조회
        function goSearch() {
            setMachinePlantSeq("","");
            fnNew();
            var param = {
                "s_maker_cd" : $M.getValue("s_maker_cd"),
                "s_machine_plant_seq_str" : $M.getValue("s_machine_plant_seq"),
            };

            $M.goNextPageAjax(this_page + '/search', $M.toGetParam(param), {method : 'get'},
                function(result) {
                    if(result.success) {
                        $("#total_cnt").html(result.total_cnt);
                        AUIGrid.setGridData(auiGridLeft, []);
                        AUIGrid.setGridData(auiGridLeft, result.list);
                        AUIGrid.setGridData(auiGridRight, []);
                    }
                }
            );
        }

        // 신규버튼
        function fnNew() {
            $M.setValue("cmd", "C");
            var param = {
                cust_app_apply_yn : 'N',
                mem_app_apply_yn : 'Y',
                break_name : '',
                trouble_seq : '0',
                temp_trouble_seq : '0'
            }

            $M.setValue(param);
            AUIGrid.clearGridData(auiGridCheck);
        }

        // 점검상세 등록
        function goAddDetail(){
            if($M.getValue("machine_plant_seq") == "") {
                alert("모델명을 선택해 주세요.");
                return false;
            }
            if($M.getValue("trouble_seq")=="0" && $M.getValue("temp_trouble_seq") =="0") {
                $M.goNextPageAjax(this_page + '/nextSeq', "", {method : 'POST'},
                    function (result){
                        if(result.success){
                            $M.setValue("temp_trouble_seq", result.trouble_seq);
                            var param = {
                                trouble_seq : $M.getValue("temp_trouble_seq"),
                            }
                            $M.goNextPage("/serv/serv0515p01", $M.toGetParam(param), {popupStatus: "", method: "GET"});
                        }
                    }
                );
            } else {
                var param = {
                    trouble_seq : $M.getValue("temp_trouble_seq") !="0" ? $M.getValue("temp_trouble_seq") : $M.getValue("trouble_seq"),
                }
                $M.goNextPage("/serv/serv0515p01", $M.toGetParam(param), {popupStatus: "", method: "GET"});
            }
        }

        // 모델명 클릭 시 모델명 세팅
        function setMachinePlantSeq(machinePlantSeq, machineName) {
            $M.setValue("machine_plant_seq", machinePlantSeq)
            $M.setValue("machine_name", machineName)
        }

        // 필수 체크
        function fnCheckValid() {
            var frm = document.main_form;
            if($M.validation(frm) == false) {
                return false;
            }
            return true;
        }

        // 미리보기
        function goPreview() {
            if($M.getValue("trouble_seq") == "0") {
                alert("고장증상을 선택해 주세요.");
                return false;
            }
            if (fnCheckValid() == false) {
                return false;
            }

            var param = {
                "trouble_seq" : $M.getValue("trouble_seq")
            }

            $M.goNextPage("/serv/serv0515p02", $M.toGetParam(param), {popupStatus: "", method: "post"});
        }

        // 첫번째 그리드(모델목록)
        function createAUIGridLeft() {
            var gridPros = {
                rowIdField : "_$uid",
                showRowNumColumn: true,
                // 칼럼 끝에서 오른쪽 이동 시 다음 행, 처음 칼럼으로 이동할지 여부
                wrapSelectionMove : false,
                enableFilter :true,
            };
            var columnLayout = [
                {
                    headerText : "메이커",
                    dataField : "maker_name",
                    style : "aui-center",
                    minWith : "65",
                    editable : false,
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "모델명",
                    dataField : "machine_name",
                    style : "aui-center aui-link",
                    minWith : "80",
                    editable : false,
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "고장증상수",
                    dataField: "trouble_cnt",
                    width: "80",
                    minWith : "50",
                    style: "aui-center",
                    editable: false,
                    filter : {
                        showIcon : true
                    }
                },
                {
                    headerText : "장비번호",
                    dataField : "machine_plant_seq",
                    visible : false,
                },
            ];
            // 실제로 #grid_wrap 에 그리드 생성
            auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
            // 그리드 갱신
            AUIGrid.setGridData(auiGridLeft, []);
            AUIGrid.bind(auiGridLeft, "cellClick", function(event){
                if (event.dataField == "machine_name") {
                    var machinePlantSeq = event.item["machine_plant_seq"];
                    var machineName = event.item["machine_name"];
                    setMachinePlantSeq(machinePlantSeq, machineName);   // 점검상세에 모델명 세팅
                    goSearchTrouble(machinePlantSeq);   // 고장증상 검색
                    AUIGrid.setGridData(auiGridRight, []);
                }
            });
        }

        // 모델명 클릭시
        function goSearchTrouble(machinePlantSeq) {
            var param = {
                "machine_plant_seq" : machinePlantSeq
            };
            $M.goNextPageAjax(this_page + "/trouble", $M.toGetParam(param),{ method : 'get'},
                function(result) {
                    if(result.success){
                        fnNew();
                        AUIGrid.setGridData(auiGridRight, result.list);
                    }
                }
            );
        }

        // 점검항목 클릭 시
        function goSearchCheckDetail(troubleSeq) {
            var param = {
                "trouble_seq" : troubleSeq,
            };
            $M.goNextPageAjax(this_page + "/checkDetail", $M.toGetParam(param),{ method : 'get'},
                function(result) {
                    if(result.success){
                        var detail = result.detail;
                        var data = result.checkList;
                        AUIGrid.setGridData(auiGridCheck, data);
                        $M.setValue(detail);
                    }
                }
            );
        }

        function fnAddTrouble(troubleSeq) {
            var param = {
                trouble_seq : troubleSeq
            }
            $M.goNextPageAjax(this_page + "/troubleDetails", $M.toGetParam(param),{ method : 'get'},
                function(result) {
                    if(result.success){
                        var data = result.checkList;
                        AUIGrid.setGridData(auiGridCheck, data);
                    }
                }
            );
        }

        // 앱적용
        function goAppApply() {
            var machinePlantSeq = $M.getValue("machine_plant_seq");

            var gridData = AUIGrid.getGridData(auiGridRight);
            var changeGridData = AUIGrid.getEditedRowItems(auiGridRight); // 변경내역
            if(gridData.length == 0 || changeGridData.length == 0) {
                var message = "";
                gridData.length == 0 ? message = "적용할 데이터가 없습니다." : message = "변경된 내용이 없습니다.";
                alert(message);
                return;
            }
            var concatCols = [];
            var concatList = [];
            var gridIds = [auiGridRight];

            for (var i = 0; i < gridIds.length; ++i) {
                concatList = concatList.concat(AUIGrid.exportToObject(gridIds[i]));
                concatCols = concatCols.concat(fnGetColumns(gridIds[i]));
            }
            var gridFrm = fnGridDataToForm(concatCols, concatList);


            $M.goNextPageAjaxSave(this_page + "/appApplySave", gridFrm, {method: "POST"},
                function (result) {
                    if (result.success) {
                        goSearchTrouble(machinePlantSeq);
                    }
                }
            );


        }

        // 저장
        function goSave() {
            if($M.getValue("machine_plant_seq") == "") {
                alert("모델명을 선택해 주세요.");
                return false;
            }
            if (fnCheckValid() == false) {
                return false;
            }
            if(AUIGrid.getRowCount(auiGridCheck) == 0) {
                alert("점검 상세를 등록해 주세요.");
                return false;
            }

            if($M.getValue("trouble_seq") == "0") { // 신규 저장시 trouble_seq에 temp_trouble_seq있을 시 동일 입력
                if($M.getValue("temp_trouble_seq") != "0") {
                    $M.setValue("trouble_seq", $M.getValue("temp_trouble_seq"));
                }
            }

            var frm = document.main_form;
            frm = $M.toValueForm(frm);
            // $M.setValue(frm, "cust_app_apply_yn", $M.getValue("cust_app_apply_yn") == "" ? "N" : "Y");
            // $M.setValue(frm, "mem_app_apply_yn", $M.getValue("mem_app_apply_yn") == "" ? "N" : "Y");

            $M.goNextPageAjaxSave(this_page + '/save', frm, {method : 'POST'},
                function(result) {
                    if(result.success) {
                        goSearchTrouble($M.getValue("machine_plant_seq"));
                    }
                }
            );
        }

        // 삭제
        function goRemove() {
            if($M.getValue("trouble_seq") == "0") {
                alert("삭제할 데이터가 없습니다.");
                return false;
            }
            var param = {
                "trouble_seq" : $M.getValue("trouble_seq")
            }
            $M.goNextPageAjaxMsg("삭제하시겠습니까?", this_page + "/remove", $M.toGetParam(param), { method : "POST"},
                function(result) {
                    if(result.success) {
                        goSearchTrouble($M.getValue("machine_plant_seq"));
                    }
                }
            );

        }

        // 두번째 그리드(점검항목)
        function createAUIGridRight() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                editable: true
            };
            var columnLayout = [
                {
                    headerText: "고장증상",
                    dataField: "break_name",
                    editable: false,
                    style: "aui-left aui-link"
                },
                {
                    headerText : "고객앱",
                    dataField : "cust_app_apply_yn",
                    width : "10%",
                    style : "aui-center",
                    renderer : {
                        type : "CheckBoxEditRenderer",
                        editable : true,
                        checkValue : "Y",
                        unCheckValue : "N"
                    }
                },
                {
                    headerText : "직원앱",
                    dataField : "mem_app_apply_yn",
                    width : "10%",
                    style : "aui-center",
                    renderer : {
                        type : "CheckBoxEditRenderer",
                        editable : true,
                        checkValue : "Y",
                        unCheckValue : "N"
                    }
                },
                {
                    headerText: "트러블슈팅번호",
                    dataField: "trouble_seq",
                    visible : false
                },
                {
                    headerText: "장비번호",
                    dataField: "machine_plant_seq",
                    visible : false
                },
            ];
            // 실제로 #grid_wrap 에 그리드 생성
            auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGridRight, []);

            AUIGrid.bind(auiGridRight, "cellClick", function(event){
                if (event.dataField == "break_name") {
                    $M.setValue("cmd", "U");
                    var troubleSeq = event.item["trouble_seq"];
                    goSearchCheckDetail(troubleSeq);

                }
            });
        }

        // 세번째 점검상세 그리드
        function createAUIGridCheck() {
            var gridPros = {
                rowIdField: "_$uid",
                showRowNumColumn: true,
                editable: true
            };
            var columnLayout = [
                {
                    headerText: "점검상세",
                    dataField: "check_text",
                    editable: false,
                    style: "aui-left"
                },
                {
                    headerText: "이미지 파일 수",
                    dataField: "file_cnt",
                    editable: false,
                    style: "aui-center aui-link",
                    width: "100"
                },
                {
                    dataField: "img_file_seq_1",
                    visible : false
                },
                {
                    dataField: "img_file_seq_2",
                    visible : false
                },
                {
                    dataField: "img_file_seq_3",
                    visible : false
                },
                {
                    dataField: "img_file_seq_4",
                    visible : false
                },
                {
                    dataField: "img_file_seq_5",
                    visible : false
                },
                {
                    headerText: "순번",
                    dataField: "seq_no",
                    visible : false
                },
                {
                    headerText: "트러블슈팅번호",
                    dataField: "trouble_seq",
                    visible : false
                },
            ];
            // 실제로 #grid_wrap 에 그리드 생성
            auiGridCheck = AUIGrid.create("#auiGridCheck", columnLayout, gridPros);

            // 그리드 갱신
            AUIGrid.setGridData(auiGridCheck, []);

            AUIGrid.bind(auiGridCheck, "cellClick", function(event){
                if (event.dataField == "file_cnt") {
                    var param = {
                        "trouble_seq" : event.item.trouble_seq,
                        "seq_no" : event.item.seq_no
                    };

                    var poppupOption = "";
                    $M.goNextPage('/serv/serv0515p03', $M.toGetParam(param), {popupStatus : poppupOption});
                }
            });
        }

    </script>
</head>
<body>
<!-- contents 전체 영역 -->
<form id="main_form" name="main_form">
    <input type="hidden" id="trouble_seq" name="trouble_seq" value="0"/>
    <input type="hidden" id="temp_trouble_seq" name="temp_trouble_seq" value="0"/>
    <input type="hidden" id="cmd" name="cmd" value="C">
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
                            <col width="50px">
                            <col width="250px">
                            <col width="50px">
                            <col width="300px">
                            <col width="*">
                        </colgroup>
                        <tbody>
                        <tr>
                            <th>메이커</th>
                            <td>
                                <div class="icon-btn-cancel-wrap">
                                    <select class="form-control" id="s_maker_cd" name="s_maker_cd"  >
                                        <option value="">- 전체 -</option>
                                        <c:forEach var="item" items="${makerList}">
                                            <option value="${item.maker_cd}">${item.maker_name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                            </td>
                            <th>모델명</th>
                            <td>
                                <input type="text" style="width : 300px;"
                                       id="s_machine_plant_seq"
                                       name="s_machine_plant_seq"
                                       easyui="combogrid"
                                       header="Y"
                                       easyuiname="machineList"
                                       panelwidth="300"
                                       maxheight="300"
                                       textfield="machine_name"
                                       multi="Y"
                                       idfield="machine_plant_seq" />
                            </td>
                            <td class="">
                                <button type="button" onclick="javascript:goSearch();" class="btn btn-important" style="width: 50px;">조회</button>
                            </td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <!-- /검색영역 -->
                <div class="row">
                    <!-- 메뉴목록 -->
                    <div class="col-3">
                        <div class="title-wrap mt10">
                            <h4>모델목록</h4>
                        </div>
                        <div id="auiGridLeft" style="margin-top: 5px;height: 500px;"></div>
                    </div>
                    <div class="col-4">
                        <div class="title-wrap mt10">
                            <h4>고장증상</h4>
                            <div class="right">
                                <button type="button" class="btn btn-outline-primary" style="height: 28px" onclick="javascript:goAppApply();">고객앱 직원앱 적용</button>
                            </div>
                        </div>
                        <div id="auiGridRight" style="margin-top: 5px;height: 500px;"></div>
                    </div>
                    <div class="col-5">
                        <div class="title-wrap mt10">
                            <h4>점검상세</h4>
                        </div>
                        <div style="margin-top: 5px;" >
                            <table class="table-border" id="checkDtlTable">
                                <colgroup>
                                    <col width="80px">
                                    <col width="">
                                </colgroup>
                                <tbody >
                                <tr>
                                    <th class="text-right essential-item">모델명</th>
                                    <td>
                                        <input type="text" class="form-control width280px" id="machine_name" name="machine_name" alt="모델명" required="required" readonly >
                                        <input type="hidden" id="machine_plant_seq" name="machine_plant_seq" required="required">
                                    </td>
                                </tr>
<%--                                <tr>--%>
<%--                                    <th class="text-right">적용여부</th>--%>
<%--                                    <td>--%>
<%--                                        <div class="btn-group">--%>
<%--                                            <div class="inline-pd" style="margin-left: 5px">--%>
<%--                                                <div class="form-check form-check-inline checkline">--%>
<%--                                                    <input class="form-check-input" type="checkbox" id="cust_app_apply_yn" name="cust_app_apply_yn" value="Y" >--%>
<%--                                                    <label class="form-check-label" for="cust_app_apply_yn">고객앱 적용</label>--%>
<%--                                                </div>--%>
<%--                                                <div class="form-check form-check-inline checkline">--%>
<%--                                                    <input class="form-check-input ml10" type="checkbox" id="mem_app_apply_yn" name="mem_app_apply_yn" value="Y" checked>--%>
<%--                                                    <label class="form-check-label" for="mem_app_apply_yn">직원앱 적용</label>--%>
<%--                                                </div>--%>
<%--                                            </div>--%>
<%--                                        </div>--%>
<%--                                    </td>--%>
<%--                                </tr>--%>
                                <tr>
                                    <th class="text-right essential-item">고장증상</th>
                                    <td>
                                        <input type="text" id="break_name" name="break_name" class="form-control essential-bg" alt="고장증상" required="required" maxlength="100">
                                    </td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <div class="btn-group mt10">
                            <div class="right">
                                <button type="button" class="btn btn-outline-primary mt5" onclick="javascript:goAddDetail();">상세등록</button>
                            </div>
                        </div>
                        <div id="auiGridCheck" style="margin-top: 5px;height: 385px;"></div>
                    </div>
                    <!-- /메뉴목록 -->
                </div>
                <div class="btn-group mt5">
                    <div class="left">
                        총 <strong class="text-primary" id="total_cnt" >0</strong>건
                    </div>
                </div>
                <div class="btn-group mt5">
                    <div class="right">
                        <jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
                    </div>
                </div>
            </div>
        </div>
        <jsp:include page="/WEB-INF/jsp/common/footer.jsp"/>
    </div>
    <!-- /contents 전체 영역 -->
</form>
</body>
</html>
