<%@ page contentType="text/html;charset=utf-8" language="java"%><jsp:include page="/WEB-INF/jsp/common/commonForAll.jsp"/><%@ taglib prefix="c" uri="http://java.sun.com/jstl/core_rt" %><%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %><%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %><%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %><%@ taglib uri="http://www.springframework.org/tags/form" prefix="form"%>
<%------------------------------------------------------------------------------------------------------------------
-- 업   무 : 서비스 > 서비스관리 > 서비스캠페인 > 캠페인 신규등록 > null
-- 작성자 : 손광진
-- 최초 작성일 : 2020-04-08 13:24:29
------------------------------------------------------------------------------------------------------------------%>
<!DOCTYPE html>
<html>
<head>
	<jsp:include page="/WEB-INF/jsp/common/auiHeader.jsp"/>
	<script type="text/javascript">
		// 첨부파일의 index 변수
		var fileIndex = 1;
		
		var auiGridLeft;
		var auiGridRight;
		
		$(document).ready(function () {
			createAUIGridLeft();
			createAUIGridRight();
			fnInitDate();
		});
	
		
		// 캠페인 시작일자 세팅 현재날짜의 1달 전
		function fnInitDate() {
			var now = "${inputParam.s_current_dt}";
			$M.setValue("campaign_st_dt", $M.addMonths($M.toDate(now), -1));
		}
	
		// 장비조회
		function goSearch() {
	
			if($M.checkRangeByFieldName("s_out_st_dt", "s_out_end_dt", true) == false) {				
				return;
			};
	
			var param = {
				"s_machine_name" 	: $M.getValue("s_machine_name"),
				"s_out_st_dt" 		: $M.getValue("s_out_st_dt"),
				"s_out_end_dt" 		: $M.getValue("s_out_end_dt"),
				"s_body_no_st" 		: $M.getValue("s_body_no_st"),
				"s_body_no_end" 	: $M.getValue("s_body_no_end"),
				"s_sort_key" 		: "vm.body_no",
				"s_sort_method" 	: "desc"
			};
			console.log(param);
			$M.goNextPageAjax(this_page + "/search", $M.toGetParam(param), {method : "get"},
				function(result) {
					if(result.success) {
						AUIGrid.setGridData(auiGridLeft, result.list);
						$("#total_cnt").html(result.total_cnt);
					}
				}
			);
		}
		
		function goSave() {
	
			var frm = $M.toValueForm(document.main_form);
			 
			if($M.validation(frm) == false) { 
				return;
			} 
	
			if($M.validation(document.main_form, {field:["campaign_name","campaign_st_dt","campaign_end_dt","content"]}) == false) {
				return;
			};
	
			if (fnChangeGridDataCnt(auiGridRight) == 0) {
				alert("대상자목록을 추가하세요.");
				return false;
			};
			
			var gridForm  = fnChangeGridDataToForm(auiGridRight);
	
			//$M.copyForm(frm, gridForm);
	
			$M.copyForm(gridForm, frm);
	
			console.log(frm);
	
			console.log(gridForm);
			 	
			$M.goNextPageAjaxSave(this_page + '/insert', gridForm , {method : 'POST'},			
				function(result) {
					if(result.success) {
						$M.goNextPage("/serv/serv0506");
					}
				}
			); 
			
		}
	
		function fnList() {
			$M.goNextPage("/serv/serv0506");
		}
	
		function fnAddFile() {
			openFileUploadPanel('setFileInfo', 'upload_type=BBS&file_type=both&max_size=2048');
		}
	
		function setFileInfo(result) {
			var str = ''; 
			str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.bbs_file_div').append(str);
			fileIndex++;
		}	
	
		// 첨부파일 삭제
		function fnRemoveFile(fileIndex, fileSeq) {
			var result = confirm("파일을 삭제하시겠습니까?\n삭제 후 복구는 불가능 합니다.");
			if (result) {
				$(".bbs_file_" + fileIndex).remove();
			} else {
				return false;
			}	
		}
	
		// 첨부파일 출력
	 	function fnPrintFile(fileSeq, fileName) {
	 		var str = ''; 
			str += '<div class="table-attfile-item bbs_file_' + fileIndex + '" style="float:left; display:block;">';
			str += '<a href="javascript:fileDownload(' + result.file_seq + ');" style="color: blue;">' + result.file_name + '</a>&nbsp;';
			str += '<input type="hidden" name="file_seq" value="' + result.file_seq + '"/>';
			str += '<button type="button" class="btn-default" onclick="javascript:fnRemoveFile(' + fileIndex + ', ' + result.file_seq + ')"><i class="material-iconsclose font-18 text-default"></i></button>';
			str += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
			str += '</div>';
			$('.bbs_file_div').append(str);
			fileIndex++;
		}
	
		// 해당 장비의 차대번호 조회
		function goMachinePopup(setName) {
			
			var param = {
				"s_machine_name" 	: $M.getValue("s_machine_name"),
			};
			openSearchDeviceHisPanel(setName, $M.toGetParam(param));
		}
		
		
		//차대번호 세팅(시작)
		function fnSetVINSt(data) {
			$M.setValue("s_body_no_st", data.body_no);
		}
	
		//차대번호 세팅(끝)
		function fnSetVINEnd(data) {
			$M.setValue("s_body_no_end", data.body_no);
		}
		
		//대상자 추가
		function fnAdd() {
	
			// 조회결과 그리드의 체크된 행값
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridLeft);
			// 대상자목록 그리드에 있는 데이터
			var gridRightList = AUIGrid.getGridData(auiGridRight);
	
		
			// 선택된 행이 없을 때
			if(rows.length < 1) {
				alert("조회결과에 선택된 행이 없습니다.");
				return;
			};
			
			// 중복체크
			for(var i = 0; i < rows.length; i++) {
				for(var j = 0; j < gridRightList.length; j++) {
					if(rows[i]["machine_seq"] == gridRightList[j]["machine_seq"]) {
						alert("차대번호 : " + rows[i]["body_no"] + "은 이미 대상자목록에 추가된 장비 입니다.");
						return false;
					};
				}
			}
			
			// 얻은 행 대상자목록 그리드에 추가하기
			AUIGrid.addRow(auiGridRight, rows, "last");
			
			// 조회결과에서 체크된 행들 체크해제
			AUIGrid.setAllCheckedRows(auiGridLeft, false);
			
		}
	
		
		// 대상자목록 체크된 행 삭제
		function fnRemove() {
			
			// 그리드의 체크된 행들 얻기
			var rows = AUIGrid.getCheckedRowItemsAll(auiGridRight);
			if(rows.length <= 0) {
				alert(msg.alert.data.noChecked);
				return;
			}
			// 체크된 행 삭제
			AUIGrid.removeCheckedRows(auiGridRight);

		}
	
		function fnDownloadExcel() {
			  // 엑셀 내보내기 속성
			  var exportProps = {};
			  fnExportExcel(auiGridRight, "서비스캠페인", exportProps);
		};
	
		function createAUIGridLeft() {
			
			var gridPros = {
				// rowIdField 설정
				rowIdField: "machine_seq",
				// 체크박스 출력 여부
				showRowCheckColumn : true,
				// 전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,
				// Row번호 표시 여부
				showRowNumColum : true
			};
			
	
			var columnLayout = [
				{
					headerText : "machine_seq",
					dataField : "machine_seq",
					visible : false
				},
				{
					headerText : "장비명",
					dataField : "machine_name"
				},
				{
					headerText : "차대번호",
					dataField : "body_no"
				},
				{
					headerText : "출하일",
					dataField  : "out_dt",
					dataType : "date",
					formatString : "yyyy-mm-dd"
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridLeft = AUIGrid.create("#auiGridLeft", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridLeft, []);
		}
		
	
		function createAUIGridRight() {
			var gridPros = {
				rowIdField : "$_uid",
				// rowNumber 
				showRowNumColumn: true,
				//체크박스 출력 여부
				showRowCheckColumn : true,
				//전체선택 체크박스 표시 여부
				showRowAllCheckBox : true,	
				enableFilter : true,
				// 행 소프트 제거 모드
				softRemoveRowMode : true,	
			};
	
	
			var columnLayout = [
				{
					dataField : "machine_seq",
					visible : false
				},
				{
					headerText : "모델명",
					dataField  : "machine_name",
					width: "20%",
					style : "aui-center"
				},
				{
					headerText : "차대번호",
					dataField  : "body_no",
					width: "20%",
				},
				{
					headerText : "고객명",
					dataField : "cust_name",
					width: "10%",
				},
				{
					headerText : "휴대폰",
					dataField : "hp_no",
					width : "15%",
				},
				{
					headerText : "센터",
					dataField : "center_org_name",
					width : "10%",
				},
				{
					headerText : "지역",
					dataField : "area_do",
					width : "10%",
				},
				{
					headerText : "담당자",
					dataField : "sale_mem_name",
					width : "10%",
				},
				{
					headerText : "가동시간",
					dataField : "op_hour",
					dataType : "numeric",
					formatString : "#,##0",
					width : "10%",
				},
				{
					headerText : "삭제",
					dataField : "removeBtn",
					renderer : {
						type : "ButtonRenderer",
						onClick : function(event) {
							var isRemoved = AUIGrid.isRemovedById(auiGridRight, event.item._$uid);
							console.log(isRemoved);
							if (isRemoved == false) {
								AUIGrid.removeRow(event.pid, event.rowIndex);								
							} else {
								AUIGrid.restoreSoftRows(auiGrid, "selectedIndex"); 
							};
						},
					},
					labelFunction : function(rowIndex, columnIndex, value,
							headerText, item) {
						return '삭제'
					},
					style : "aui-center",
					editable : false
				}
			];
	
			// 실제로 #grid_wrap에 그리드 생성
			auiGridRight = AUIGrid.create("#auiGridRight", columnLayout, gridPros);
			// 그리드 갱신
			AUIGrid.setGridData(auiGridRight, []);
		}
	</script>
</head>
<body>
	<form id="main_form" name="main_form">
		<div class="layout-box">
			<!-- contents 전체 영역 -->
			<div class="content-wrap">
				<div class="content-box">
	<!-- 상세페이지 타이틀 -->
					<div class="main-title detail">
						<div class="detail-left">
							<button type="button" class="btn btn-outline-light" onclick="javascript:fnList();"><i class="material-iconskeyboard_backspace text-default"></i></button>
							<jsp:include page="/WEB-INF/jsp/common/menuNavi.jsp"/>
						</div>
					</div>
	<!-- /상세페이지 타이틀 -->
					<div class="contents">
						<div class="row">
							<div class="col-5">
	<!-- 캠페인명 -->				
								<div>
									<div class="title-wrap">
										<h4>캠페인명</h4>				
									</div>
									<table class="table-border mt5">
										<colgroup>
											<col width="100px">
											<col width="">
										</colgroup>
										<tbody>
											<tr>
												<th class="text-right essential-item" >제목</th>
												<td>
													<input type="text" class="form-control" id="campaign_name" name="campaign_name" alt="제목">
												</td>
											</tr>
											<tr>
												<th class="text-right essential-item">기간</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width120px">
															<div class="input-group">
																<input type="text" class="form-control border-right-0 calDate" id="campaign_st_dt" name="campaign_st_dt" dateFormat="yyyy-MM-dd" value="" alt="캠페인 시작일">
															</div>
														</div>
														<div class="col width16px">~</div>
														<div class="col width120px">
															<div class="input-group">
																<input type="text" class="form-control border-right-0 calDate" id="campaign_ed_dt" name="campaign_ed_dt" dateFormat="yyyy-MM-dd"  value="${inputParam.s_current_dt}" alt="캠페인 종료일">
															</div>
														</div>
													</div>
												</td>
											</tr>
											<tr>
												<th class="text-right essential-item">내용</th>
												<td>
													<textarea class="form-control" style="height: 100px;" id="content" name="content" alt="내용"></textarea>
												</td>
											</tr>
											<tr>
												<th class="text-right">이미지첨부</th>
												<td>
													<div class="table-attfile bbs_file_div" style="width:100%;">
														<div class="table-attfile" style="float:left">
															<button type="button" class="btn btn-primary-gra mr10" name="fileAddBtn" id="fileAddBtn" onclick="javascript:fnAddFile();">파일찾기</button>
														</div>
													</div>
												</td>
											</tr>																			
										</tbody>
									</table>
								</div>
	<!-- /캠페인명 -->		
	<!-- 대상자선별 -->				
								<div>
									<div class="title-wrap mt10">
										<h4>대상자선별</h4>				
									</div>
									<table class="table-border mt5">
										<colgroup>
											<col width="100px">
											<col width="">
										</colgroup>
										<tbody>
											<tr>
												<th class="text-right">장비명</th>
												<td>
													<div class="form-row">
														<div class="col-3">
															<jsp:include page="/WEB-INF/jsp/common/searchMachine.jsp">
									                     		<jsp:param name="required_field" value="s_machine_name"/>
									                     		<jsp:param name="s_maker_cd" value=""/>
									                     		<jsp:param name="s_machine_type_cd" value=""/>
									                     		<jsp:param name="s_sale_yn" value=""/>
									                     		<jsp:param name="readonly_field" value=""/>
									                     	</jsp:include>
								                     	</div>
							                     	</div>
												</td>
											</tr>
											<tr>
												<th class="text-right">차대번호</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width120px">
															<div class="input-group width120px">
																<input type="text" id="s_body_no_st" name="s_body_no_st" class="form-control border-right-0" placeholder="시작">
																<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachinePopup('fnSetVINSt');"><i class="material-iconssearch"></i></button>
															</div>
														</div>
														<div class="col width16px">~</div>
														<div class="col width120px">
															<div class="input-group width120px">
																<input type="text" id="s_body_no_end" name="s_body_no_end" class="form-control border-right-0" placeholder="끝">
																<button type="button" class="btn btn-icon btn-primary-gra" onclick="javascript:goMachinePopup('fnSetVINEnd');"><i class="material-iconssearch"></i></button>
															</div>
														</div>
													</div>
												</td>
											</tr>	
											<tr>
												<th class="text-right">출하일자</th>
												<td>
													<div class="form-row inline-pd widthfix">
														<div class="col width120px">
															<div class="input-group">
																<input type="text" class="form-control border-right-0 calDate" id="s_out_st_dt" name="s_out_st_dt" dateFormat="yyyy-MM-dd" alt="출하일자 시작">
															</div>
														</div>
														<div class="col width16px">~</div>
														<div class="col width120px">
															<div class="input-group">
																<input type="text" class="form-control border-right-0 calDate" id="s_out_end_dt" name="s_out_end_dt" dateFormat="yyyy-MM-dd" alt="출하일자 종료">
															</div>
														</div>
														<div class="col width60px">
															<button type="button" class="btn btn-important" style="width: 100%;" onclick="javascript:goSearch();">조회</button>
														</div>
													</div>
												</td>
											</tr>																	
										</tbody>
									</table>
								</div>
	<!-- /대상자선별 -->
	<!-- 조회결과 -->				
								<div>
									<div class="title-wrap mt10">
										<h4>조회결과</h4>
										<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="MID_M"/></jsp:include>
									</div>
									<div id="auiGridLeft" style="margin-top: 5px; height: 140px;"></div>
								</div>
	<!-- /조회결과 -->							
							</div>
							<div class="col-7">
	<!-- 대상자목록 -->				
								<div>
									<div class="title-wrap">
										<h4>대상자목록</h4>	
										<div class="right">
											<jsp:include page="/WEB-INF/jsp/common/buttonAuth.jsp"><jsp:param name="pos" value="TOP_R"/></jsp:include>
										</div>
									</div>
									<div id="auiGridRight" style="margin-top: 5px; height: 555px;"></div>
								</div>
	<!-- /대상자목록 -->							
							</div>
						</div>
						<div class="btn-group mt10">
							<div class="left">
								총 <strong class="text-primary" id="total_cnt">0</strong>건
							</div>
							<div class="right">
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