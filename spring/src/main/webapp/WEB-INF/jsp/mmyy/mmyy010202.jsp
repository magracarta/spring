<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : MY > MY > 쪽지함 > null > null
-- 작성자 : 이종술
-- 최초 작성일 : 2020-04-09 11:51:27
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
	
		$(document).ready(function() {
			createAUIGrid();
			
			$("#btnHideMid").children().eq(0).attr('id','btngoMove');
			$("#btnHideMid").children().eq(1).attr('id','btnfnDownloadExcel');
			
			$('#btngoMove').css('margin-left','1px');
			$('#btnfnDownloadExcel').css('margin-left','1px');
			parent.fnNonReadCnt($M.getValue('s_start_dt'), $M.getValue('s_end_dt'), "S");
		});
		
		// 엔터키 이벤트
		function enter(fieldObj) {
			var field = ["s_send_name","s_receiver_name","s_paper_contents", "s_read_yn","s_confirm_yn"];
			$.each(field, function() {
				if(fieldObj.name == this) {
					goSearch();
				};
			});
		}
		
		// 조회
		function goSearch() { 
			// 조회 버튼 눌렀을경우 1페이지로 초기화
			page = 1;
			moreFlag = "N";
			fnSearch(function(result){
				AUIGrid.setGridData(auiGrid, result.list);
				$("#total_cnt").html(result.total_cnt);
				$("#curr_cnt").html(result.list.length);
				if (result.more_yn == 'Y') {
					moreFlag = "Y";
					page++;
				};
			});
		}
		
		//조회
		function fnSearch(successFunc) {
			if($M.checkRangeByFieldName('s_start_dt', 's_end_dt', true) == false) {				
				return;
			} 
			isLoading = true;
			var param = {
					"s_start_dt" : $M.getValue('s_start_dt'),
					"s_end_dt" : $M.getValue('s_end_dt'),
					"s_receiver_name" : $M.getValue('s_receiver_name'),
					"s_paper_contents" : $M.getValue('s_paper_contents'),
					"s_read_yn" : $M.getValue('s_read_yn'),
					"s_confirm_yn" : $M.getValue('s_confirm_yn'),
					"s_sort_key" : "send_date",
					"s_sort_method" : "desc",
					"page" : page,
					"rows" : $M.getValue("s_rows")
			};
			_fnAddSearchDt(param, 's_start_dt', 's_end_dt');
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : 'get'},
				function(result) {
					isLoading = false;
					if(result.success) {
						successFunc(result);
						parent.fnNonReadCnt($M.getValue('s_start_dt'), $M.getValue('s_end_dt'), "S");
					};
				}
			);
		}
		
		// 스크롤 위치가 마지막과 일치한다면 추가 데이터 요청함
		function fnScollChangeHandelr(event) {
			if(event.position == event.maxPosition && moreFlag == "Y"  && isLoading == false) {
				goMoreData();
			};
		}
		
		function goMoreData() {
			fnSearch(function(result){
				result.more_yn == "N" ? moreFlag = "N" : page++;  
				if (result.list.length > 0) {
					console.log(result.list);
					AUIGrid.appendData("#auiGrid", result.list);
					$("#curr_cnt").html(AUIGrid.getGridData(auiGrid).length);
				};
			});
		}

		//엑셀다운
		function fnDownloadExcel() {
			var exportProps = {
			         // 제외항목
			  };
		  	fnExportExcel(auiGrid, "보낸쪽지함", exportProps);
		}

		//쪽지쓰기 팝어
		function goSend() {
			var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=1000, height=670, left=0, top=0";
			$M.goNextPage('/mmyy/mmyy0102p01/', '', {popupStatus : poppupOption});
		}

		//쪽지함 이동
		function goMove() {
			var itemArr = AUIGrid.getCheckedRowItemsAll(auiGrid);
			
			if($M.getValue('p_paper_box_seq') == ''){
				alert("이동할 쪽지함을 선택해주세요.");
				return;
			}else if(itemArr.length == 0){
				alert('선택된 쪽지가 없습니다.');
				return;
			}
			
			var param = [];
			for(var i = 0 ; i < itemArr.length ; i++){
				var data = {
					'paper_seq' : itemArr[i].paper_seq,
					'paper_box_seq' : $M.getValue('p_paper_box_seq'),
					'mem_no' : '${SecureUser.mem_no}',
					'cmd' : "S",
				}
				
				param.push(data);
			}
			
			var msg ="선택한 쪽지를 이동하시겠습니까?";
			
			var frm = $M.jsonArrayToForm(param);
			
			$M.goNextPageAjaxMsg(msg,"/mmyy/mmyy0102/move", frm, {method : 'post'},
				function(result) {
					if(result.success) {
						goSearch();
					};
				}
			);
		}

		
		function createAUIGrid() {
			var gridPros = {
				rowIdField : "_$uid",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true,
				rowHeight : 30,
				rowCheckableWithDisabled : true,
				rowCheckableFunction : function(rowIndex, isChecked, item) {
					if(item.send_mem_no != '${SecureUser.mem_no}' && item.mem_no != '${SecureUser.mem_no}') {
						return false;
					}
					return true;
				}
			};

			var columnLayout = [
				{
					headerText : "쪽지번호",
					dataField : "paper_seq",
					visible : false
				},
				{
					headerText : "받는이",
					dataField : "receiver_name",
					width : "6%"
				},
				{
					headerText : "선택쪽지함",
					dataField : "send_box_name",
					width : "8%"
				},
				{
					headerText : "쪽지내용",
					dataField : "paper_contents",
					style : "aui-left aui-popup"
				},
				{
					headerText : "수신일시",
					dataField : "send_date",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center",
					width : "10%"
				},
				{
					headerText : "확인일시",
					dataField : "read_date",
					dataType : "date",
					formatString : "yy-mm-dd HH:MM:ss",
					style : "aui-center",
					width : "10%"
				},
				{
					headerText : "첨부파일",
					dataField : "file_yn",
					width : "5%"
				}/* ,
				{
					headerText : "수신여부",
					dataField : "stat_name",
					width : "5%"
				} */
			];

			// 실제로 #grid_wrap에 그리드 생성
			auiGrid = AUIGrid.create("#auiGrid", columnLayout, gridPros);

			AUIGrid.bind(auiGrid, "cellClick", function(event) {
				if(event.dataField == "paper_contents") {
					var param = {
						"s_paper_seq" : event.item["paper_seq"],
						"s_paper_type" : 'SEND'
					};
					var poppupOption = "scrollbars=no, resizable=1, menubar=no, toolbar=no, location=no, directories=no, status=no, fullscreen=no, width=850, height=700, left=0, top=0";
					$M.goNextPage('/mmyy/mmyy0102p02', $M.toGetParam(param), {popupStatus : poppupOption});
				}
			});
			
			AUIGrid.bind(auiGrid, "vScrollChange", fnScollChangeHandelr);
		}
	</script>
</head>
<body>
<form id="main_form" name="main_form">
	<div class="layout-box">
		<!-- contents 전체 영역 -->
		<div class="content-wrap" style="padding:0;">
			<div class="content-box">
				<div class="contents">
					<!-- 기본 -->
					<div class="search-wrap mt10">
						<table class="table">
							<colgroup>
								<col width="60px">
								<col width="260px">
								<col width="50px">
								<col width="100px">
								<col width="40px">
								<col width="190px">
								<col width="60px">
								<col width="80px">
								<%-- <col width="60px">
								<col width="80px"> --%>
								<col width="">
							</colgroup>
							<tbody>
							<tr>
								<th>조회기간</th>
								<td>
									<div class="form-row inline-pd widthfix">
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_start_dt" name="s_start_dt" dateFormat="yyyy-MM-dd" value="${searchDtMap.s_start_dt}" alt="조회 시작일">
											</div>
										</div>
										<div class="col-auto">~</div>
										<div class="col-5">
											<div class="input-group">
												<input type="text" class="form-control border-right-0 calDate" id="s_end_dt" name="s_end_dt" dateFormat="yyyy-MM-dd"  value="${searchDtMap.s_end_dt}" alt="조회 완료일">
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
								<th>받는이</th>
								<td>
									<input type="text" class="form-control" id="s_receiver_name" name="s_receiver_name" >
								</td>
								<th>내용</th>
								<td>
									<input type="text" class="form-control" id="s_paper_contents" name="s_paper_contents">
								</td>
								<th>확인구분</th>
								<td>
									<select class="form-control" id="s_read_yn" name="s_read_yn">
										<option value="">- 전체 -</option>
										<option value="N">읽지않음</option>
										<option value="Y">읽음</option>
									</select>
								</td>
								<!-- <th>미결구분</th>
								<td>
									<select class="form-control" id="s_confirm_yn" name="s_confirm_yn">
										<option value="">- 전체 -</option>
										<option value="Y">미결</option>
									</select>
								</td> -->
								<td>
									<button type="button" class="btn btn-important" style="width: 50px;" onclick="javascript:goSearch()">조회</button>
								</td>
							</tr>
							</tbody>
						</table>
					</div>
					<!-- /기본 -->
					<!-- 그리드 타이틀, 컨트롤 영역 -->
					<div class="title-wrap mt10">
						<h4>보낸쪽지</h4>
						<div class="btn-group">
							<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
								<div class="btn-group">
									<div class="right dpf">
										<select class="form-control mr3" style="width: 150px;" id="p_paper_box_seq" name="p_paper_box_seq">
											<option value="">쪽지함 선택</option>
											<c:forEach var="data" items="${list }">
												<option value="${data.paper_box_seq }">${data.box_name }</option>
											</c:forEach>
										</select>
										<div id="btnHideMid">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_R"/></jsp:include>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>
					<!-- /그리드 타이틀, 컨트롤 영역 -->
					<div id="auiGrid" style="margin-top: 5px; height: 480px;"></div>
					<!-- 그리드 서머리, 컨트롤 영역 -->
					<div class="btn-group mt5">
						<div class="left">
							<jsp:include page="/WEB-INF/jsp/common/pagingFooter.jsp"/>
						</div>
						<div class="right"><%-- 버튼위치는 pos param 에 따라 나옴 (없으면 기본 상단나옴) T_CODE.CODE_VALUE='BTN_POS' 참고 --%>
							<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="BOM_R"/></jsp:include>
						</div>
					</div>
				</div>
			</div>
		</div>
		<!-- /contents 전체 영역 -->
	</div>
</form>
</body>
</html>